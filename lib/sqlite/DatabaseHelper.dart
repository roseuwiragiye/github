import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, 'quiz_database.db');

    return await openDatabase(databasePath, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
          CREATE TABLE quizzes(
            id TEXT PRIMARY KEY,
            title TEXT,
            description TEXT
          )
          ''');

      await db.execute('''
          CREATE TABLE questions(
            id TEXT PRIMARY KEY,
            quiz_id TEXT,
            question TEXT,
            answers TEXT,
            correct_answer_index INTEGER,
            FOREIGN KEY (quiz_id) REFERENCES quizzes(id)
          )
          ''');
    });
  }

  // Sync data from Firestore to SQLite
  Future<void> syncFromFirestore() async {
    final Database db = await database;
    final QuerySnapshot quizzesSnapshot =
        await FirebaseFirestore.instance.collection('quizzes').get();

    final batch = db.batch();

    quizzesSnapshot.docs.forEach((quizDoc) {
      batch.insert(
        'quizzes',
        {
          'id': quizDoc.id,
          'title': quizDoc['title'],
          'description': quizDoc['description'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      FirebaseFirestore.instance
          .collection('quizzes')
          .doc(quizDoc.id)
          .collection('questions')
          .get()
          .then((questionsSnapshot) {
        questionsSnapshot.docs.forEach((questionDoc) {
          batch.insert(
            'questions',
            {
              'id': questionDoc.id,
              'quiz_id': quizDoc.id,
              'question': questionDoc['question'],
              'answers': questionDoc['answers'],
              'correct_answer_index': questionDoc['correctAnswerIndex'],
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        });
      });
    });

    await batch.commit(noResult: true);
  }

  // Sync data from Firestore to SQLite and vice versa
  Future<void> syncData() async {
    await syncFromFirestore();
    await syncToFirestore();
  }

  // Sync data from SQLite to Firestore
  Future<void> syncToFirestore() async {
    final Database db = await database;
    final QuerySnapshot localQuizzesSnapshot =
        await FirebaseFirestore.instance.collection('quizzes').get();
    final List<String> localQuizIds =
        localQuizzesSnapshot.docs.map((doc) => doc.id).toList();

    final batch = FirebaseFirestore.instance.batch();

    final List<Map<String, dynamic>> localQuizzes =
        await db.rawQuery('SELECT * FROM quizzes');
    final List<Map<String, dynamic>> localQuestions =
        await db.rawQuery('SELECT * FROM questions');

    localQuizzes.forEach((quiz) {
      if (!localQuizIds.contains(quiz['id'])) {
        final quizRef = FirebaseFirestore.instance.collection('quizzes').doc(quiz['id']);
        batch.set(quizRef, {
          'title': quiz['title'],
          'description': quiz['description'],
        });
      }
    });

    localQuestions.forEach((question) {
      final questionRef = FirebaseFirestore.instance
          .collection('quizzes')
          .doc(question['quiz_id'])
          .collection('questions')
          .doc(question['id']);
      batch.set(questionRef, {
        'question': question['question'],
        'answers': question['answers'],
        'correctAnswerIndex': question['correct_answer_index'],
      });
    });

    await batch.commit();
  }

  // Stream data from Firestore and update SQLite
  Stream<List<Map<String, dynamic>>> streamQuizzesFromFirestore() {
    return FirebaseFirestore.instance.collection('quizzes').snapshots().asyncMap((snapshot) async {
      final Database db = await database;

      final batch = db.batch();

      for (final change in snapshot.docChanges) {
        final doc = change.doc;
        if (change.type == DocumentChangeType.added || change.type == DocumentChangeType.modified) {
          batch.insert(
            'quizzes',
            {
              'id': doc.id,
              'title': doc['title'],
              'description': doc['description'],
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          final questionsSnapshot =
              await doc.reference.collection('questions').get();
          questionsSnapshot.docs.forEach((questionDoc) {
            batch.insert(
              'questions',
              {
                'id': questionDoc.id,
                'quiz_id': doc.id,
                'question': questionDoc['question'],
                'answers': questionDoc['answers'],
                'correct_answer_index': questionDoc['correctAnswerIndex'],
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          });
        } else if (change.type == DocumentChangeType.removed) {
          batch.delete('quizzes', where: 'id = ?', whereArgs: [doc.id]);
          batch.delete('questions', where: 'quiz_id = ?', whereArgs: [doc.id]);
        }
      }

      await batch.commit(noResult: true);

      final quizzes = await db.rawQuery('SELECT * FROM quizzes');
      return quizzes;
    });
  }
}
