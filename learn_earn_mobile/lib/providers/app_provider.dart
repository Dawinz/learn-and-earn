import 'package:flutter/foundation.dart';
import '../models/lesson.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../services/ad_service.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/connectivity_service.dart';
import '../constants/app_constants.dart';

class AppProvider extends ChangeNotifier {
  int _coins = 1000; // Starting coins
  List<Lesson> _lessons = [];
  List<Transaction> _transactions = [];
  DateTime? _lastResetDate;
  DateTime? _lastDailyLogin;
  int _learningStreak = 0;
  DateTime? _lastStreakDate;
  User? _user;
  bool _isAuthenticated = false;
  bool _isOnline = true;

  // Getters
  int get coins => _coins;
  List<Lesson> get lessons => _lessons;
  List<Transaction> get transactions => _transactions;
  int get learningStreak => _learningStreak;
  DateTime? get lastStreakDate => _lastStreakDate;
  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isOnline => _isOnline;

  AppProvider() {
    _initializeData();
  }

  Future<void> initialize() async {
    // Initialize connectivity service
    await ConnectivityService().initialize();

    // Check authentication status first
    await _checkAuthStatus();
    await _loadData();
    await _checkDailyReset();
    // Preload ads after data is loaded
    await AdService.preloadAds();
  }

  // Check authentication status
  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    if (isLoggedIn) {
      final user = await AuthService.getCurrentUser();
      if (user != null) {
        _user = user;
        _isAuthenticated = true;
        notifyListeners();
      }
    }
  }

  // Set user after successful authentication
  Future<void> setUser(User user) async {
    _user = user;
    _isAuthenticated = true;
    notifyListeners();
  }

  // Update connectivity status
  void updateConnectivityStatus(bool isOnline) {
    _isOnline = isOnline;
    notifyListeners();
  }

  // Logout user
  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> _loadData() async {
    // Check backend health first
    final isBackendOnline = await ApiService.checkHealth();

    if (isBackendOnline) {
      try {
        // Register device with backend
        final deviceData = await ApiService.registerDevice();
        if (kDebugMode) {
          print('Device registered: ${deviceData['deviceId']}');
        }

        // Load lessons from backend
        final backendLessons = await ApiService.getLessons();
        if (backendLessons.isNotEmpty) {
          _lessons = backendLessons;
          if (kDebugMode) {
            print('Loaded ${backendLessons.length} lessons from backend');
          }
        } else {
          if (kDebugMode) {
            print('No lessons from backend, using local data');
          }
          _initializeData();
        }

        // Load earnings from backend
        final backendEarnings = await ApiService.getEarningsHistory();
        if (backendEarnings.isNotEmpty) {
          _transactions = backendEarnings;
          if (kDebugMode) {
            print('Loaded ${backendEarnings.length} transactions from backend');
          }
        }

        // Load user profile from backend
        final userProfile = await ApiService.getUserProfile();
        if (userProfile.isNotEmpty) {
          if (kDebugMode) {
            print('User profile loaded: $userProfile');
          }
        }

        // Calculate coins from transactions
        _coins = _transactions.fold(
          1000,
          (sum, transaction) => sum + transaction.amount,
        );

        // Save data locally for offline access
        await _saveData();
      } catch (e) {
        print('Error loading from backend: $e');
        // Fallback to local data
        await _loadLocalData();
      }
    } else {
      print('Backend offline, using local data');
      await _loadLocalData();
    }

    notifyListeners();
  }

  Future<void> _loadLocalData() async {
    // Load saved data
    _coins = await StorageService.loadCoins();
    _lessons = await StorageService.loadLessons();
    _transactions = await StorageService.loadTransactions();
    _lastDailyLogin = await StorageService.loadLastDailyLogin();
    _learningStreak = await StorageService.loadLearningStreak();
    _lastStreakDate = await StorageService.loadLastStreakDate();

    // If no saved data, initialize with default data
    if (_lessons.isEmpty) {
      _initializeData();
    }
  }

  void _initializeData() {
    // Initialize sample lessons
    _lessons = [
      Lesson(
        id: '1',
        title: 'Introduction to Programming',
        summary: 'Master the fundamentals of programming concepts and logic',
        contentMD: '''
# Introduction to Programming

## What is Programming?
Programming is the process of creating instructions for computers to follow. It involves writing code in a specific programming language to solve problems and create applications.

## Key Concepts
- **Variables**: Store data that can change
- **Functions**: Reusable blocks of code
- **Loops**: Repeat actions multiple times
- **Conditionals**: Make decisions in code
- **Data Types**: Different kinds of information

## Why Learn Programming?
- High demand in job market
- Creative problem solving
- Build amazing applications
- Work from anywhere
- Good salary potential

## Getting Started
1. Choose a programming language
2. Set up development environment
3. Start with simple programs
4. Practice regularly
5. Build projects

## Next Steps
After mastering basics, explore:
- Object-oriented programming
- Data structures
- Algorithms
- Web development
- Mobile development
        ''',
        estMinutes: 45,
        coinReward: 75,
        category: 'Programming',
        tags: ['beginner', 'fundamentals', 'programming'],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        quiz: [
          QuizQuestion(
            question: 'What is a variable in programming?',
            options: [
              'A container that stores data',
              'A type of function',
              'A programming language',
              'A computer component',
            ],
            correctAnswer: 0,
            explanation:
                'A variable is a named container that stores data that can change during program execution.',
          ),
          QuizQuestion(
            question: 'What is the purpose of a loop?',
            options: [
              'To store data',
              'To repeat code multiple times',
              'To make decisions',
              'To create functions',
            ],
            correctAnswer: 1,
            explanation:
                'Loops allow you to repeat a block of code multiple times, making programs more efficient.',
          ),
        ],
      ),
      Lesson(
        id: '2',
        title: 'Web Development Basics',
        summary:
            'HTML, CSS, and JavaScript fundamentals for modern web development',
        contentMD: '''
# Web Development Basics

## What is Web Development?
Web development involves creating websites and web applications that run in browsers. It encompasses both the visual aspects users see and the behind-the-scenes functionality.

## Frontend vs Backend
- **Frontend**: What users see and interact with (HTML, CSS, JavaScript)
- **Backend**: Server-side logic and database management
- **Full-Stack**: Both frontend and backend development

## HTML - Structure
HTML (HyperText Markup Language) provides the structure of web pages:

```html
<!DOCTYPE html>
<html>
<head>
    <title>My Web Page</title>
</head>
<body>
    <h1>Welcome</h1>
    <p>This is a paragraph.</p>
</body>
</html>
```

## CSS - Styling
CSS (Cascading Style Sheets) makes web pages look beautiful:

```css
h1 {
    color: blue;
    font-size: 24px;
}

p {
    color: gray;
    line-height: 1.5;
}
```

## JavaScript - Interactivity
JavaScript adds dynamic behavior to web pages:

```javascript
function greetUser() {
    const name = prompt('What is your name?');
    alert('Hello, ' + name + '!');
}
```

## Modern Web Development
- **Responsive Design**: Works on all devices
- **Progressive Web Apps**: App-like web experiences
- **Web APIs**: Connect to external services
- **Frameworks**: React, Vue, Angular for complex apps
        ''',
        estMinutes: 60,
        coinReward: 100,
        category: 'Web Development',
        tags: ['html', 'css', 'javascript', 'frontend'],
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        quiz: [
          QuizQuestion(
            question: 'What does HTML stand for?',
            options: [
              'HyperText Markup Language',
              'High Tech Modern Language',
              'Home Tool Markup Language',
              'Hyperlink and Text Markup Language',
            ],
            correctAnswer: 0,
            explanation: 'HTML stands for HyperText Markup Language.',
          ),
          QuizQuestion(
            question: 'What is the purpose of CSS?',
            options: [
              'To create web pages',
              'To style web pages',
              'To add interactivity',
              'To store data',
            ],
            correctAnswer: 1,
            explanation: 'CSS is used to style and format web pages.',
          ),
        ],
      ),
      Lesson(
        id: '3',
        title: 'Mobile App Development',
        summary: 'Build cross-platform mobile apps with Flutter and Dart',
        contentMD: '''
# Mobile App Development

## What is Mobile App Development?
Mobile app development is the process of creating software applications that run on mobile devices like smartphones and tablets.

## Types of Mobile Development
- **Native Apps**: Built specifically for one platform (iOS/Android)
- **Cross-Platform**: One codebase for multiple platforms
- **Web Apps**: Run in mobile browsers
- **Hybrid Apps**: Combine web and native technologies

## Why Flutter?
Flutter is Google's UI toolkit for building natively compiled applications:

### Advantages
- **Single Codebase**: Write once, run everywhere
- **Fast Development**: Hot reload for quick iterations
- **Native Performance**: Compiled to native code
- **Rich Widgets**: Beautiful, customizable UI components
- **Strong Community**: Large ecosystem and support

## Flutter Architecture
```
┌─────────────────┐
│   Dart Code     │
├─────────────────┤
│   Flutter SDK   │
├─────────────────┤
│   Engine (C++)  │
├─────────────────┤
│   Platform      │
└─────────────────┘
```

## Basic Flutter App
```dart
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Demo')),
      body: Center(child: Text('Hello, Flutter!')),
    );
  }
}
```

## Key Concepts
- **Widgets**: Everything in Flutter is a widget
- **State Management**: Managing app state
- **Navigation**: Moving between screens
- **Layout**: Arranging widgets on screen
        ''',
        estMinutes: 75,
        coinReward: 125,
        category: 'Mobile Development',
        tags: ['flutter', 'dart', 'mobile', 'cross-platform'],
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        quiz: [
          QuizQuestion(
            question: 'What programming language does Flutter use?',
            options: ['Java', 'Kotlin', 'Dart', 'Swift'],
            correctAnswer: 2,
            explanation: 'Flutter uses Dart as its programming language.',
          ),
          QuizQuestion(
            question: 'What is the main advantage of Flutter?',
            options: [
              'It only works on Android',
              'Write once, run everywhere',
              'It requires separate code for each platform',
              'It only works on iOS',
            ],
            correctAnswer: 1,
            explanation:
                'Flutter allows you to write code once and run it on multiple platforms.',
          ),
        ],
      ),
      Lesson(
        id: '4',
        title: 'Data Structures & Algorithms',
        summary:
            'Master essential computer science concepts for efficient programming',
        contentMD: '''
# Data Structures & Algorithms

## What are Data Structures?
Data structures are ways of organizing and storing data in a computer so that it can be accessed and modified efficiently.

## Common Data Structures

### Arrays
- **Static Arrays**: Fixed size, indexed collection
- **Dynamic Arrays**: Resizable arrays
- **Time Complexity**: O(1) access, O(n) insertion/deletion

### Linked Lists
- **Singly Linked**: Each node points to the next
- **Doubly Linked**: Each node points to next and previous
- **Time Complexity**: O(n) access, O(1) insertion/deletion

### Stacks
- **LIFO**: Last In, First Out
- **Operations**: Push, Pop, Peek
- **Use Cases**: Function calls, undo operations

### Queues
- **FIFO**: First In, First Out
- **Operations**: Enqueue, Dequeue
- **Use Cases**: Task scheduling, breadth-first search

## Algorithms

### Sorting Algorithms
- **Bubble Sort**: O(n²) - Simple but inefficient
- **Quick Sort**: O(n log n) average - Divide and conquer
- **Merge Sort**: O(n log n) - Stable sorting
- **Heap Sort**: O(n log n) - In-place sorting

### Search Algorithms
- **Linear Search**: O(n) - Check each element
- **Binary Search**: O(log n) - Divide and conquer
- **Hash Table**: O(1) average - Key-value lookup

## Big O Notation
Measures algorithm efficiency:
- **O(1)**: Constant time
- **O(log n)**: Logarithmic time
- **O(n)**: Linear time
- **O(n²)**: Quadratic time
- **O(2ⁿ)**: Exponential time

## Best Practices
- Choose the right data structure for your problem
- Consider time vs space complexity
- Practice implementing from scratch
- Understand when to use each algorithm
        ''',
        estMinutes: 90,
        coinReward: 150,
        category: 'Computer Science',
        tags: ['algorithms', 'data-structures', 'computer-science'],
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        quiz: [
          QuizQuestion(
            question: 'What does LIFO stand for in stack operations?',
            options: [
              'Last In, First Out',
              'First In, First Out',
              'Last In, Last Out',
              'First In, Last Out',
            ],
            correctAnswer: 0,
            explanation:
                'LIFO stands for Last In, First Out, which describes how stacks work.',
          ),
          QuizQuestion(
            question: 'What is the time complexity of binary search?',
            options: ['O(1)', 'O(log n)', 'O(n)', 'O(n²)'],
            correctAnswer: 1,
            explanation:
                'Binary search has O(log n) time complexity because it eliminates half the search space each iteration.',
          ),
        ],
      ),
      Lesson(
        id: '5',
        title: 'Database Design',
        summary:
            'Master database design principles and SQL for efficient data management',
        contentMD: '''
# Database Design

## What is Database Design?
Database design is the process of creating a database schema that efficiently stores and retrieves data while maintaining data integrity and performance.

## Types of Databases
- **Relational (SQL)**: Tables with relationships (MySQL, PostgreSQL)
- **NoSQL**: Document, key-value, graph databases (MongoDB, Redis)
- **In-Memory**: Fast access for caching (Redis, Memcached)

## Database Design Process
1. **Requirements Analysis**: Understand data needs
2. **Conceptual Design**: Create entity-relationship diagrams
3. **Logical Design**: Define tables and relationships
4. **Physical Design**: Optimize for performance

## Normalization
Process of organizing data to reduce redundancy:

### First Normal Form (1NF)
- Eliminate duplicate columns
- Each cell contains atomic values
- No repeating groups

### Second Normal Form (2NF)
- Must be in 1NF
- Remove partial dependencies
- All non-key attributes depend on primary key

### Third Normal Form (3NF)
- Must be in 2NF
- Remove transitive dependencies
- No non-key attribute depends on another non-key attribute

## SQL Basics
```sql
-- Create table
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert data
INSERT INTO users (name, email) 
VALUES ('John Doe', 'john@example.com');

-- Query data
SELECT * FROM users WHERE name LIKE 'John%';

-- Update data
UPDATE users SET email = 'newemail@example.com' 
WHERE id = 1;

-- Delete data
DELETE FROM users WHERE id = 1;
```

## Relationships
- **One-to-One**: Each record in Table A relates to one record in Table B
- **One-to-Many**: One record in Table A relates to many records in Table B
- **Many-to-Many**: Many records in Table A relate to many records in Table B

## Indexing
Improves query performance:
```sql
-- Create index
CREATE INDEX idx_email ON users(email);

-- Composite index
CREATE INDEX idx_name_email ON users(name, email);
```

## Best Practices
- Use meaningful table and column names
- Always use primary keys
- Normalize appropriately (not over-normalize)
- Use indexes for frequently queried columns
- Plan for scalability
- Regular backups
        ''',
        estMinutes: 60,
        coinReward: 100,
        category: 'Database',
        tags: ['sql', 'database', 'normalization', 'design'],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
        quiz: [
          QuizQuestion(
            question: 'What does SQL stand for?',
            options: [
              'Structured Query Language',
              'Standard Query Language',
              'Simple Query Language',
              'System Query Language',
            ],
            correctAnswer: 0,
            explanation: 'SQL stands for Structured Query Language.',
          ),
          QuizQuestion(
            question: 'What is the purpose of database normalization?',
            options: [
              'To make databases faster',
              'To reduce data redundancy and improve integrity',
              'To increase storage space',
              'To make queries simpler',
            ],
            correctAnswer: 1,
            explanation:
                'Normalization reduces data redundancy and improves data integrity by organizing data efficiently.',
          ),
        ],
      ),

      // Additional comprehensive lessons
      Lesson(
        id: '6',
        title: 'Python Programming Fundamentals',
        summary:
            'Master Python syntax, data types, and control structures for modern development',
        contentMD: '''
# Python Programming Fundamentals

## Introduction to Python
Python is a high-level, interpreted programming language known for its simplicity and readability. It's perfect for beginners and widely used in data science, web development, and automation.

## Python Syntax
```python
# Comments start with #
print("Hello, World!")

# Variables
name = "John"
age = 25
is_student = True
```

## Data Types
- **Strings**: Text data ("Hello")
- **Integers**: Whole numbers (42)
- **Floats**: Decimal numbers (3.14)
- **Booleans**: True/False values
- **Lists**: Ordered collections [1, 2, 3]
- **Dictionaries**: Key-value pairs {"name": "John"}

## Control Structures
### If Statements
```python
if age >= 18:
    print("You are an adult")
elif age >= 13:
    print("You are a teenager")
else:
    print("You are a child")
```

### Loops
```python
# For loop
for i in range(5):
    print(i)

# While loop
count = 0
while count < 5:
    print(count)
    count += 1
```

## Functions
```python
def greet(name):
    return f"Hello, {name}!"

# Call the function
message = greet("Alice")
print(message)
```

## Best Practices
- Use meaningful variable names
- Write comments for complex code
- Follow PEP 8 style guide
- Test your code regularly
        ''',
        estMinutes: 60,
        coinReward: 100,
        category: 'Programming',
        tags: ['python', 'beginner', 'syntax', 'fundamentals'],
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        quiz: [
          QuizQuestion(
            question: 'Which symbol is used for comments in Python?',
            options: ['//', '#', '/*', '--'],
            correctAnswer: 1,
            explanation: 'Python uses the # symbol for single-line comments.',
          ),
          QuizQuestion(
            question: 'What is the correct way to create a list in Python?',
            options: ['list(1, 2, 3)', '[1, 2, 3]', '{1, 2, 3}', '(1, 2, 3)'],
            correctAnswer: 1,
            explanation:
                'Lists in Python are created using square brackets [].',
          ),
        ],
      ),

      Lesson(
        id: '7',
        title: 'CSS Styling and Layout',
        summary:
            'Learn CSS properties, selectors, and modern layout techniques',
        contentMD: '''
# CSS Styling and Layout

## What is CSS?
CSS (Cascading Style Sheets) is used to style and format HTML elements. It controls the appearance, layout, and presentation of web pages.

## CSS Syntax
```css
selector {
    property: value;
    property: value;
}

/* Example */
h1 {
    color: blue;
    font-size: 24px;
    text-align: center;
}
```

## CSS Selectors
### Basic Selectors
```css
/* Element selector */
p { color: red; }

/* Class selector */
.highlight { background-color: yellow; }

/* ID selector */
#header { font-size: 32px; }

/* Universal selector */
* { margin: 0; padding: 0; }
```

## Flexbox Layout
```css
.container {
    display: flex;
    justify-content: center; /* Horizontal alignment */
    align-items: center;     /* Vertical alignment */
    flex-direction: row;     /* or column */
    flex-wrap: wrap;
}

.item {
    flex: 1; /* Grow to fill space */
    flex-basis: 200px; /* Base width */
}
```

## Responsive Design
```css
/* Mobile first approach */
.container {
    width: 100%;
    padding: 10px;
}

/* Tablet */
@media (min-width: 768px) {
    .container {
        max-width: 750px;
        margin: 0 auto;
    }
}

/* Desktop */
@media (min-width: 1024px) {
    .container {
        max-width: 1200px;
    }
}
```

## Best Practices
- Use external stylesheets
- Organize CSS with comments
- Use meaningful class names
- Follow a naming convention (BEM)
- Minimize CSS specificity
        ''',
        estMinutes: 70,
        coinReward: 120,
        category: 'Web Development',
        tags: ['css', 'styling', 'layout', 'responsive'],
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        updatedAt: DateTime.now(),
        quiz: [
          QuizQuestion(
            question: 'What does CSS stand for?',
            options: [
              'Cascading Style Sheets',
              'Computer Style Sheets',
              'Creative Style Sheets',
              'Colorful Style Sheets',
            ],
            correctAnswer: 0,
            explanation: 'CSS stands for Cascading Style Sheets.',
          ),
          QuizQuestion(
            question: 'Which property is used to change text color?',
            options: ['text-color', 'color', 'font-color', 'text-style'],
            correctAnswer: 1,
            explanation:
                'The color property is used to change text color in CSS.',
          ),
        ],
      ),

      Lesson(
        id: '8',
        title: 'Data Science with Python',
        summary:
            'Introduction to data analysis, visualization, and machine learning',
        contentMD: '''
# Data Science with Python

## What is Data Science?
Data Science is an interdisciplinary field that uses scientific methods, processes, algorithms, and systems to extract knowledge and insights from data.

## Key Libraries
- **NumPy**: Numerical computing
- **Pandas**: Data manipulation and analysis
- **Matplotlib**: Data visualization
- **Seaborn**: Statistical data visualization
- **Scikit-learn**: Machine learning

## Data Analysis Workflow
1. **Data Collection**: Gather data from various sources
2. **Data Cleaning**: Handle missing values and outliers
3. **Exploratory Data Analysis**: Understand data patterns
4. **Feature Engineering**: Create new features
5. **Model Building**: Apply machine learning algorithms
6. **Model Evaluation**: Assess model performance
7. **Deployment**: Put model into production

## Working with Pandas
```python
import pandas as pd
import numpy as np

# Create DataFrame
data = {
    'Name': ['Alice', 'Bob', 'Charlie'],
    'Age': [25, 30, 35],
    'Salary': [50000, 60000, 70000]
}
df = pd.DataFrame(data)

# Basic operations
print(df.head())        # First 5 rows
print(df.info())        # Data types and info
print(df.describe())    # Statistical summary
```

## Data Visualization
```python
import matplotlib.pyplot as plt
import seaborn as sns

# Line plot
plt.plot(df['Age'], df['Salary'])
plt.xlabel('Age')
plt.ylabel('Salary')
plt.title('Age vs Salary')
plt.show()

# Scatter plot
plt.scatter(df['Age'], df['Salary'])
plt.show()
```

## Machine Learning Basics
```python
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error

# Prepare data
X = df[['Age']]  # Features
y = df['Salary']  # Target

# Split data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Train model
model = LinearRegression()
model.fit(X_train, y_train)

# Make predictions
predictions = model.predict(X_test)
```

## Best Practices
- Always explore data before modeling
- Use appropriate visualizations
- Handle missing data carefully
- Validate your models
- Document your process
        ''',
        estMinutes: 80,
        coinReward: 130,
        category: 'Data Science',
        tags: ['python', 'data-science', 'pandas', 'machine-learning'],
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        updatedAt: DateTime.now(),
        quiz: [
          QuizQuestion(
            question: 'Which library is used for data manipulation in Python?',
            options: ['NumPy', 'Pandas', 'Matplotlib', 'Scikit-learn'],
            correctAnswer: 1,
            explanation:
                'Pandas is the primary library for data manipulation and analysis in Python.',
          ),
          QuizQuestion(
            question: 'What is the first step in the data science workflow?',
            options: [
              'Data Cleaning',
              'Data Collection',
              'Model Building',
              'Data Visualization',
            ],
            correctAnswer: 1,
            explanation:
                'Data Collection is the first step in the data science workflow.',
          ),
        ],
      ),

      Lesson(
        id: '9',
        title: 'Cloud Computing with AWS',
        summary:
            'Learn Amazon Web Services, cloud architecture, and deployment',
        contentMD: '''
# Cloud Computing with AWS

## What is Cloud Computing?
Cloud computing is the delivery of computing services over the internet, including servers, storage, databases, networking, software, and analytics.

## Benefits of Cloud Computing
- **Cost Effective**: Pay only for what you use
- **Scalable**: Easily scale up or down
- **Reliable**: High availability and redundancy
- **Secure**: Enterprise-grade security
- **Flexible**: Access from anywhere
- **Fast**: Quick deployment and updates

## AWS Core Services
### Compute Services
- **EC2 (Elastic Compute Cloud)**: Virtual servers
- **Lambda**: Serverless computing
- **ECS**: Container management
- **Elastic Beanstalk**: Application deployment

### Storage Services
- **S3 (Simple Storage Service)**: Object storage
- **EBS (Elastic Block Store)**: Block storage
- **EFS (Elastic File System)**: File storage
- **Glacier**: Long-term archival storage

### Database Services
- **RDS (Relational Database Service)**: Managed databases
- **DynamoDB**: NoSQL database
- **Redshift**: Data warehouse
- **ElastiCache**: In-memory caching

## Getting Started with EC2
### Launch an Instance
1. Go to EC2 Dashboard
2. Click "Launch Instance"
3. Choose an AMI (Amazon Machine Image)
4. Select instance type
5. Configure security groups
6. Launch and connect

## S3 Storage
```bash
# Create a bucket
aws s3 mb s3://my-bucket-name

# Upload files
aws s3 cp file.txt s3://my-bucket-name/
aws s3 sync ./local-folder s3://my-bucket-name/
```

## Lambda Functions
```python
import json

def lambda_handler(event, context):
    # Your code here
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
```

## Best Practices
- Use IAM for access management
- Enable CloudTrail for logging
- Use CloudWatch for monitoring
- Implement auto-scaling
- Use multiple availability zones
        ''',
        estMinutes: 75,
        coinReward: 140,
        category: 'Cloud Computing',
        tags: ['aws', 'cloud', 'deployment', 'serverless'],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now(),
        quiz: [
          QuizQuestion(
            question: 'What does AWS stand for?',
            options: [
              'Amazon Web Services',
              'Advanced Web Systems',
              'Automated Web Solutions',
              'Application Web Services',
            ],
            correctAnswer: 0,
            explanation: 'AWS stands for Amazon Web Services.',
          ),
          QuizQuestion(
            question: 'Which AWS service provides virtual servers?',
            options: ['S3', 'EC2', 'Lambda', 'RDS'],
            correctAnswer: 1,
            explanation:
                'EC2 (Elastic Compute Cloud) provides virtual servers in the cloud.',
          ),
        ],
      ),

      Lesson(
        id: '10',
        title: 'Cybersecurity Fundamentals',
        summary: 'Protect systems and data from cyber threats and attacks',
        contentMD: '''
# Cybersecurity Fundamentals

## What is Cybersecurity?
Cybersecurity is the practice of protecting systems, networks, and data from digital attacks, theft, and damage.

## Common Cyber Threats
### Malware
- **Viruses**: Self-replicating malicious code
- **Trojans**: Disguised malicious software
- **Ransomware**: Encrypts data for ransom
- **Spyware**: Secretly monitors user activity

### Social Engineering
- **Phishing**: Fraudulent emails to steal information
- **Pretexting**: Creating false scenarios
- **Baiting**: Offering something enticing
- **Quid Pro Quo**: Offering services for information

## Security Principles
### CIA Triad
- **Confidentiality**: Data is only accessible to authorized users
- **Integrity**: Data remains accurate and unmodified
- **Availability**: Data and systems are accessible when needed

### Defense in Depth
Multiple layers of security controls:
1. Physical security
2. Network security
3. Application security
4. Data security
5. User awareness

## Password Security
### Strong Password Guidelines
- Minimum 12 characters
- Mix of uppercase, lowercase, numbers, symbols
- Avoid dictionary words
- Don't reuse passwords
- Use password managers

### Multi-Factor Authentication (MFA)
- Something you know (password)
- Something you have (phone, token)
- Something you are (biometric)

## Network Security
### Firewalls
```bash
# Basic firewall rules
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -j DROP
```

### VPN (Virtual Private Network)
- Encrypts internet traffic
- Hides IP address
- Secure remote access
- Bypass geo-restrictions

## Best Practices
- Keep software updated
- Use antivirus software
- Regular backups
- Employee training
- Access controls
- Monitor and log activities
        ''',
        estMinutes: 60,
        coinReward: 100,
        category: 'Cybersecurity',
        tags: ['security', 'cybersecurity', 'threats', 'protection'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
        quiz: [
          QuizQuestion(
            question: 'What does CIA stand for in cybersecurity?',
            options: [
              'Central Intelligence Agency',
              'Confidentiality, Integrity, Availability',
              'Computer Information Access',
              'Cyber Intelligence Analysis',
            ],
            correctAnswer: 1,
            explanation:
                'CIA stands for Confidentiality, Integrity, and Availability in cybersecurity.',
          ),
          QuizQuestion(
            question: 'What is the purpose of a firewall?',
            options: [
              'To store data',
              'To monitor network traffic and block threats',
              'To encrypt data',
              'To backup files',
            ],
            correctAnswer: 1,
            explanation:
                'A firewall monitors network traffic and blocks unauthorized access.',
          ),
        ],
      ),

      // Social Media Marketing Course
      Lesson(
        id: '11',
        title: 'Social Media Marketing Mastery',
        summary:
            'Learn how to build a powerful online presence and grow your audience across all platforms',
        contentMD: '''
# Social Media Marketing Mastery

## Why Social Media Matters
Social media has revolutionized how we connect, share, and do business. With billions of active users worldwide, it's the perfect platform to build your brand, connect with customers, and grow your business.

## Platform Overview
### Facebook
- **2.9 billion users** worldwide
- Best for: Community building, local business, events
- Content: Posts, videos, live streams, stories

### Instagram
- **1.4 billion users** worldwide
- Best for: Visual content, lifestyle brands, influencers
- Content: Photos, reels, stories, IGTV

### TikTok
- **1 billion users** worldwide
- Best for: Viral content, Gen Z audience, entertainment
- Content: Short videos, trends, challenges

## Content Strategy
### The 80/20 Rule
- **80%** valuable, educational, or entertaining content
- **20%** promotional content about your business

### Content Pillars
1. **Educational**: Teach your audience something new
2. **Entertainment**: Make them laugh or feel good
3. **Inspiration**: Motivate and inspire action
4. **Behind-the-scenes**: Show your process and personality

## Engagement Strategies
### Post Consistently
- Facebook: 1-2 posts per day
- Instagram: 1 post + 3-5 stories daily
- TikTok: 1-3 videos per day

### Use Hashtags Wisely
- Research trending hashtags in your niche
- Mix popular and niche-specific hashtags
- Use 5-10 hashtags per post (Instagram)
- Create branded hashtags for your business
        ''',
        estMinutes: 75,
        coinReward: 120,
        category: 'Social Media',
        tags: ['social-media', 'marketing', 'branding', 'engagement'],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now(),
        quiz: [
          QuizQuestion(
            question: 'What is the 80/20 rule in social media content?',
            options: [
              '80% promotional, 20% educational',
              '80% educational, 20% promotional',
              '80% videos, 20% images',
              '80% text, 20% visuals',
            ],
            correctAnswer: 1,
            explanation:
                'The 80/20 rule means 80% of your content should be valuable/educational and only 20% should be promotional.',
          ),
          QuizQuestion(
            question: 'Which platform is best for B2B marketing?',
            options: ['TikTok', 'Instagram', 'LinkedIn', 'Snapchat'],
            correctAnswer: 2,
            explanation:
                'LinkedIn is the best platform for B2B marketing and professional networking.',
          ),
        ],
      ),

      // Online Money Making Course
      Lesson(
        id: '12',
        title: 'How to Make Money Online',
        summary:
            'Discover proven strategies to earn money from home through various online opportunities',
        contentMD: '''
# How to Make Money Online

## Introduction to Online Income
Making money online has never been easier or more accessible. With the right strategies and dedication, you can build multiple income streams from the comfort of your home.

## Freelancing Opportunities
### Writing and Content Creation
- **Blog writing**: \$0.10-\$1.00 per word
- **Copywriting**: \$50-\$500 per project
- **Technical writing**: \$30-\$100 per hour
- **Content marketing**: \$25-\$150 per hour

### Design and Creative Services
- **Graphic design**: \$25-\$150 per hour
- **Web design**: \$50-\$200 per hour
- **Video editing**: \$30-\$100 per hour
- **Photography**: \$50-\$500 per session

## E-commerce and Selling
### Dropshipping
- Find trending products
- Set up online store (Shopify, WooCommerce)
- Market through social media
- Profit margins: 20-40%

### Digital Products
- **E-books**: \$2.99-\$19.99 per copy
- **Online courses**: \$29-\$299 per student
- **Templates and printables**: \$5-\$50 per item
- **Software tools**: \$9.99-\$99.99 per month

## Content Creation and Monetization
### YouTube Channel
- **Ad revenue**: \$1-\$5 per 1000 views
- **Sponsorships**: \$100-\$10,000 per video
- **Affiliate marketing**: 5-30% commission
- **Merchandise**: \$5-\$50 profit per item

### Blogging
- **Google AdSense**: \$0.50-\$5 per 1000 page views
- **Affiliate marketing**: 5-30% commission
- **Sponsored posts**: \$50-\$5000 per post
- **Digital products**: \$10-\$500 per sale

## Getting Started Tips
1. **Choose your niche**: Focus on what you know
2. **Start small**: Don't quit your day job immediately
3. **Build multiple streams**: Don't rely on one income source
4. **Invest in learning**: Take courses, read books
5. **Be patient**: Success takes time and consistency
        ''',
        estMinutes: 90,
        coinReward: 150,
        category: 'Online Business',
        tags: ['money-making', 'freelancing', 'e-commerce', 'passive-income'],
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        updatedAt: DateTime.now(),
        quiz: [
          QuizQuestion(
            question: 'What is the main advantage of dropshipping?',
            options: [
              'High profit margins',
              'No inventory needed',
              'Easy to set up',
              'Low competition',
            ],
            correctAnswer: 1,
            explanation:
                'Dropshipping allows you to sell products without holding inventory, reducing upfront costs and risks.',
          ),
          QuizQuestion(
            question: 'Which platform is best for selling digital products?',
            options: ['Amazon', 'eBay', 'Teachable', 'Facebook'],
            correctAnswer: 2,
            explanation:
                'Teachable is specifically designed for selling online courses and digital products.',
          ),
        ],
      ),

      // YouTube Success Course
      Lesson(
        id: '13',
        title: 'YouTube Channel Success',
        summary:
            'Learn how to start, grow, and monetize a successful YouTube channel from scratch',
        contentMD: '''
# YouTube Channel Success

## Why YouTube Matters
YouTube is the world's second-largest search engine with over 2 billion logged-in users monthly. It's a powerful platform for building an audience, sharing knowledge, and creating multiple income streams.

## Getting Started
### Choose Your Niche
- **Educational**: How-to videos, tutorials, courses
- **Entertainment**: Comedy, gaming, vlogs, challenges
- **Lifestyle**: Fashion, beauty, fitness, cooking
- **Technology**: Reviews, unboxing, tech news
- **Business**: Marketing, entrepreneurship, finance

### Channel Setup
1. **Create Google Account**: Use your business email
2. **Channel Name**: Make it memorable and brandable
3. **Channel Art**: Professional banner and profile picture
4. **About Section**: Clear description of your content
5. **Contact Info**: Email for business inquiries

## Content Strategy
### Video Types That Work
- **Tutorials**: Step-by-step how-to guides
- **Reviews**: Product or service evaluations
- **Vlogs**: Personal behind-the-scenes content
- **Lists**: Top 10, best of, worst of
- **Reactions**: Responding to trending content
- **Live Streams**: Real-time interaction with audience

### Content Planning
- **Consistency**: Upload same day/time each week
- **Series**: Create recurring content themes
- **Trending Topics**: Stay current with what's popular
- **Evergreen Content**: Timeless, valuable information
- **Seasonal Content**: Holiday and event-based videos

## Video Production
### Equipment Basics
- **Camera**: Smartphone (iPhone/Android) or DSLR
- **Lighting**: Natural light or ring light
- **Audio**: External microphone (Lavalier or shotgun)
- **Editing**: Free (DaVinci Resolve) or paid (Adobe Premiere)
- **Thumbnails**: Canva or Photoshop

### Video Structure
1. **Hook**: First 5 seconds grab attention
2. **Introduction**: Tell viewers what they'll learn
3. **Main Content**: Deliver on your promise
4. **Call to Action**: Subscribe, like, comment
5. **Outro**: Preview next video

## Monetization Strategies
### YouTube Partner Program
- **Requirements**: 1,000 subscribers + 4,000 watch hours
- **Ad Revenue**: \$1-\$5 per 1,000 views
- **Super Chat**: Direct viewer payments
- **Channel Memberships**: Monthly recurring revenue

### Affiliate Marketing
- **Amazon Associates**: 4-8% commission
- **Product links**: In description and comments
- **Honest reviews**: Build trust with audience
- **Disclosure**: Always mention affiliate relationships

### Sponsored Content
- **Brand partnerships**: \$100-\$10,000 per video
- **Product placements**: Natural integration
- **Sponsored segments**: Clear disclosure required
- **Long-term partnerships**: Ongoing collaborations
        ''',
        estMinutes: 85,
        coinReward: 140,
        category: 'Content Creation',
        tags: ['youtube', 'video-creation', 'monetization', 'content-strategy'],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
        quiz: [
          QuizQuestion(
            question: 'What are the requirements for YouTube Partner Program?',
            options: [
              '500 subscribers + 2,000 watch hours',
              '1,000 subscribers + 4,000 watch hours',
              '2,000 subscribers + 6,000 watch hours',
              '5,000 subscribers + 10,000 watch hours',
            ],
            correctAnswer: 1,
            explanation:
                'You need 1,000 subscribers and 4,000 watch hours in the past 12 months to join the YouTube Partner Program.',
          ),
          QuizQuestion(
            question: 'What is the ideal length for a YouTube video title?',
            options: [
              'Under 30 characters',
              'Under 60 characters',
              'Under 100 characters',
              'Under 150 characters',
            ],
            correctAnswer: 1,
            explanation:
                'YouTube titles should be under 60 characters to avoid being cut off in search results.',
          ),
        ],
      ),

      // Lesson 14: Content Creation & Monetization
      Lesson(
        id: '14',
        title: 'Content Creation & Monetization: Build Your Online Brand',
        summary: 'Master content creation across YouTube, blogging, and social media. Learn to monetize through ads, sponsorships, and digital products to earn \$3K-10K+ monthly.',
        contentMD: '''# Content Creation & Monetization: Build Your Online Brand

## Introduction: The Creator Economy Revolution

The creator economy is worth over \$100 billion globally. Content creators earn six and seven-figure incomes by sharing knowledge, entertainment, and expertise online. This guide will show you how to build a profitable content creation business from zero.

## Understanding the Creator Economy

### Why Content Creation Works

**The Opportunity:**
- 50+ million creators worldwide
- Average full-time creator: \$50K-150K+ annually
- Multiple revenue streams from single content
- Build once, earn forever (passive income)
- Low startup costs (\$0-500)

**Revenue Streams:**
- Ad revenue (YouTube, blog ads)
- Sponsorships and brand deals
- Affiliate marketing
- Digital products (courses, ebooks)
- Memberships/subscriptions
- Coaching and consulting
- Speaking engagements
- Merchandise

### Income Timeline

**Months 1-3: Foundation (\$0-100/month)**
- Building audience
- Creating consistently
- Learning what works
- First sponsorships

**Months 4-6: Growth (\$100-1000/month)**
- Growing 20-50%/month
- Monetization enabled
- First brand deals
- Affiliate income building

**Months 7-12: Momentum (\$1000-3000/month)**
- Established audience
- Multiple revenue streams
- Regular sponsorships
- Digital products

**Year 2+: Scale (\$3000-10,000+/month)**
- Authority in niche
- Premium sponsorships
- Course sales scaling
- Diversified income

## Phase 1: Finding Your Content Niche

### The Niche Selection Framework

**Formula:** Niche = (Skills + Passion) × Market Demand × Monetization

**High-Paying Niches:**

**Business & Finance (\$5-50+ CPM)**
- Personal finance
- Investing/stocks
- Entrepreneurship
- Real estate
- Online business

## Phase 2: YouTube Strategy

### Getting Started

**Why YouTube:**
- 2+ billion monthly users
- Best discovery algorithm
- Multiple monetization options
- Long-term passive income

**Requirements:**
- 1,000 subscribers
- 4,000 watch hours (12 months)

**Revenue Potential:**
- Ad revenue: \$2-20 per 1,000 views
- 100K views/month = \$500-2,000
- Sponsorships: \$10-50 per 1,000 views

## Conclusion

Content creation offers unlimited income potential. Success requires consistency, value creation, and patience.

**Key Takeaways:**
1. Choose profitable niche aligned with skills
2. Consistency is everything
3. Provide massive value before selling
4. Build email list from day one
5. Diversify income streams
        ''',
        estMinutes: 20,
        coinReward: 100,
        category: 'How to Make Money Online',
        tags: ['content-creation', 'youtube', 'blogging', 'social-media', 'online-income'],
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        updatedAt: DateTime.now(),
        quiz: [
          QuizQuestion(
            question: 'What is the typical ad revenue per 1,000 views on YouTube for business/finance content?',
            options: [
              '\$1-3 (CPM)',
              '\$5-50+ (CPM)',
              '\$100-200 (CPM)',
              '\$0.10-0.50 (CPM)',
            ],
            correctAnswer: 1,
            explanation: 'Business and finance content has high CPM rates of \$5-50+ per 1,000 views because advertisers in these niches pay premium prices for qualified audiences.',
          ),
          QuizQuestion(
            question: 'What is the most important factor for growing a YouTube channel in the first 1,000 subscribers?',
            options: [
              'Expensive camera equipment',
              'Consistency and quality content',
              'Paying for ads',
              'Having a large social media following',
            ],
            correctAnswer: 1,
            explanation: 'Consistency and quality content are the most important factors for growth. The YouTube algorithm rewards consistent uploading and viewer engagement.',
          ),
          QuizQuestion(
            question: 'What percentage of your content should be value-driven vs promotional?',
            options: [
              '50% value, 50% promotional',
              '60% value, 40% promotional',
              '80% value, 20% promotional',
              '100% value, 0% promotional',
            ],
            correctAnswer: 2,
            explanation: 'The 80/20 rule works best: 80% of content should provide value while only 20% should be promotional.',
          ),
        ],
      ),

      // Lesson 15: Affiliate Marketing Strategies
      Lesson(
        id: '15',
        title: 'Affiliate Marketing Mastery: Earn Commissions Promoting Products',
        summary: 'Master affiliate marketing strategies to earn passive income by promoting products you love. Learn to build trust, create converting content, and scale to \$5K-15K+ monthly.',
        contentMD: '''# Affiliate Marketing Mastery: Earn Commissions Promoting Products

## Introduction: The Power of Affiliate Marketing

Affiliate marketing is a \$17 billion industry growing 10% annually. It allows you to earn commissions by recommending products—no inventory, no customer service, no product creation.

## Understanding Affiliate Marketing

### How It Works

**The Business Model:**
1. Join an affiliate program
2. Get unique tracking links
3. Promote products to your audience
4. People buy through your links
5. You earn commission (1-75%)

**Why It Works:**
- Low startup cost (\$0-500)
- No product creation needed
- No inventory or shipping
- Passive income potential
- Scale indefinitely

### Income Potential

**Month 1-3: Learning (\$0-500)**
- Understanding your audience
- Testing different products
- Building trust

**Month 4-6: Growth (\$500-2,000)**
- Consistent content
- Building authority
- Optimizing conversions

**Month 7-12: Momentum (\$2,000-5,000)**
- Established audience
- High-converting content
- Multiple income sources

**Year 2+: Scale (\$5,000-15,000+)**
- Authority in niche
- Predictable income
- Team support

## Phase 1: Choosing Your Niche

**High-Commission Niches:**

**Software/SaaS (20-50% recurring)**
- Email marketing tools
- Website builders
- SEO tools

**Finance (Varies, \$50-300+ per lead)**
- Credit cards
- Investment platforms
- Insurance

**Online Education (30-50%)**
- Online courses
- Membership sites

## Phase 2: Finding Affiliate Programs

### Top Affiliate Networks

**Amazon Associates**
- Pros: Huge product selection
- Cons: Low commissions (1-10%)
- Best for: Physical products

**ShareASale**
- 4,000+ merchants
- Reliable tracking
- Best for: Various niches

**ClickBank**
- High commissions (50-75%)
- Best for: Digital products

## Conclusion

Affiliate marketing offers incredible passive income potential with low startup costs.

**Key Takeaways:**
1. Only promote quality products
2. Provide value before promoting
3. Build email list from day one
4. Diversify products and traffic sources
5. Always disclose affiliate relationships
        ''',
        estMinutes: 18,
        coinReward: 90,
        category: 'How to Make Money Online',
        tags: ['affiliate-marketing', 'passive-income', 'online-business', 'digital-marketing'],
        createdAt: DateTime.now().subtract(const Duration(days: 13)),
        updatedAt: DateTime.now(),
        quiz: [
          QuizQuestion(
            question: 'What is the recommended content ratio for affiliate marketing?',
            options: [
              '50% value, 50% promotion',
              '70% value, 20% soft mentions, 10% direct promotion',
              '30% value, 70% promotion',
              '90% value, 10% promotion',
            ],
            correctAnswer: 1,
            explanation: 'The 70/20/10 rule works best for building trust while monetizing effectively.',
          ),
          QuizQuestion(
            question: 'Which niche typically offers recurring commissions of 20-50%?',
            options: [
              'Physical products',
              'Software/SaaS products',
              'Books and ebooks',
              'Fashion and apparel',
            ],
            correctAnswer: 1,
            explanation: 'Software and SaaS products typically offer 20-50% recurring monthly commissions.',
          ),
          QuizQuestion(
            question: 'What is required by the FTC for affiliate marketers?',
            options: [
              'No disclosure needed',
              'Disclosure only on homepage',
              'Clear disclosure before affiliate links on every page',
              'Disclosure in website footer',
            ],
            correctAnswer: 2,
            explanation: 'The FTC requires clear and conspicuous disclosure before affiliate links on every page.',
          ),
        ],
      ),

      // Lesson 16: Virtual Assistant Services
      Lesson(
        id: '16',
        title: 'Virtual Assistant Services: Build a Flexible Remote Career',
        summary: 'Learn how to start and scale a virtual assistant business. Master in-demand skills, find high-paying clients, and earn \$2K-6K+ monthly working from anywhere.',
        contentMD: '''# Virtual Assistant Services: Build a Flexible Remote Career

## Introduction: The VA Opportunity

The virtual assistant industry is booming with over 59% of businesses now hiring VAs. It's a flexible, location-independent career with low startup costs and high earning potential.

## Understanding Virtual Assistant Work

### What is a Virtual Assistant?

A VA provides administrative, technical, or creative assistance to clients remotely. Services range from email management to social media marketing.

**Why VA Work is Growing:**
- Remote work revolution
- Business cost savings
- Global talent pool
- Flexible arrangements

### Income Potential

**Beginners (\$10-20/hour)**
- Basic admin tasks
- Email management
- Data entry
- Scheduling

**Intermediate (\$20-35/hour)**
- Social media management
- Content writing
- Customer service
- Bookkeeping

**Advanced (\$35-75+/hour)**
- Project management
- Web development
- Graphic design
- Marketing strategy

## Phase 1: Choosing Your Services

**Popular VA Services:**

**Administrative**
- Email management
- Calendar scheduling
- Travel booking
- Document preparation

**Social Media**
- Content creation
- Post scheduling
- Community management
- Analytics reporting

**Content & Marketing**
- Blog writing
- Newsletter creation
- SEO optimization
- Email campaigns

## Phase 2: Finding Clients

**Freelance Platforms:**
- Upwork
- Fiverr
- Freelancer.com
- Belay

**Direct Outreach:**
- LinkedIn networking
- Cold email campaigns
- Referrals
- Local business groups

## Conclusion

Virtual assistant work offers flexibility and growth potential.

**Key Takeaways:**
1. Start with 2-3 core services
2. Communication and reliability are key
3. Build portfolio with testimonials
4. Set clear boundaries and rates
5. Continuously learn new skills
        ''',
        estMinutes: 17,
        coinReward: 85,
        category: 'How to Make Money Online',
        tags: ['virtual-assistant', 'remote-work', 'freelancing', 'online-business'],
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        updatedAt: DateTime.now(),
        quiz: [
          QuizQuestion(
            question: 'What is the typical hourly rate for an experienced VA specializing in a technical skill?',
            options: [
              '\$5-10/hour',
              '\$10-15/hour',
              '\$20-35/hour',
              '\$50-100/hour',
            ],
            correctAnswer: 2,
            explanation: 'Experienced VAs with specialized technical skills typically charge \$20-35/hour or more.',
          ),
          QuizQuestion(
            question: 'Which platform is best for beginners starting their VA career?',
            options: [
              'Only work with local businesses',
              'Upwork and other freelance platforms',
              'Start your own agency immediately',
              'Wait until you have 5 years of experience',
            ],
            correctAnswer: 1,
            explanation: 'Upwork and similar platforms provide access to clients and built-in payment protection.',
          ),
          QuizQuestion(
            question: 'What is the most important skill for VA success?',
            options: [
              'Technical expertise only',
              'Communication and reliability',
              'Working the most hours',
              'Having expensive equipment',
            ],
            correctAnswer: 1,
            explanation: 'Communication and reliability are most important for VA success.',
          ),
        ],
      ),

      // Lesson 17: Print on Demand Business
      Lesson(
        id: '17',
        title: 'Print on Demand: Create & Sell Custom Products',
        summary: 'Build a profitable print-on-demand business with zero inventory. Learn design, marketing, and scaling strategies to reach \$3K-8K+ monthly passive income.',
        contentMD: '''# Print on Demand: Create & Sell Custom Products

## Introduction: The POD Revolution

Print-on-demand eliminates inventory risk while allowing you to sell custom products worldwide. No upfront costs, no storage, no shipping headaches.

## Understanding Print on Demand

### How POD Works

1. Create designs for products
2. Upload to POD platform
3. Customer orders product
4. POD service prints and ships
5. You earn profit margin

**Benefits:**
- No inventory investment
- No shipping logistics
- Global reach
- Passive income potential
- Low startup costs (\$0-200)

### Income Potential

**Month 1-3: Foundation (\$0-300)**
- Creating designs
- Testing niches
- Learning platforms
- First sales

**Month 4-6: Growth (\$300-1,500)**
- Refined designs
- Better marketing
- Growing catalog
- Repeat customers

**Month 7-12: Momentum (\$1,500-3,000)**
- Popular designs
- Multiple products
- Brand recognition
- Scaling ads

**Year 2+: Scale (\$3,000-8,000+)**
- Established brand
- Diverse product line
- Multiple sales channels
- Automated systems

## Phase 1: Choosing Your Niche

**Profitable Niches:**

**Hobbies & Interests**
- Pets
- Gaming
- Fitness
- Crafts

**Professions**
- Teachers
- Nurses
- Engineers
- Developers

**Life Events**
- Weddings
- Birthdays
- Graduations
- Holidays

## Phase 2: Platform Selection

**Best POD Platforms:**

**Printful**
- Best quality
- Wide product range
- Integration with stores

**Printify**
- Competitive pricing
- Many print providers
- Good variety

**Redbubble**
- Built-in marketplace
- Easy to start
- Lower profit margins

## Phase 3: Design Strategy

**Design Tools:**
- Canva (beginner-friendly)
- Adobe Illustrator (professional)
- Photoshop (photo editing)

**Design Tips:**
- Keep it simple
- High resolution
- Niche-specific
- Test variations

## Conclusion

Print-on-demand rewards creativity and smart marketing.

**Key Takeaways:**
1. Choose targeted niche
2. Create unique designs
3. Test multiple products
4. Market consistently
5. Scale what works
        ''',
        estMinutes: 19,
        coinReward: 95,
        category: 'How to Make Money Online',
        tags: ['print-on-demand', 'e-commerce', 'passive-income', 'design'],
        createdAt: DateTime.now().subtract(const Duration(days: 11)),
        updatedAt: DateTime.now(),
        quiz: [
          QuizQuestion(
            question: 'What is the typical profit margin for print-on-demand products?',
            options: [
              '5-10%',
              '20-40%',
              '60-80%',
              '90-100%',
            ],
            correctAnswer: 1,
            explanation: 'Typical POD profit margins are 20-40%.',
          ),
          QuizQuestion(
            question: 'Which platform is best for beginners starting POD?',
            options: [
              'Building your own website first',
              'Etsy + Printful integration',
              'Amazon only',
              'Wholesale to retail stores',
            ],
            correctAnswer: 1,
            explanation: 'Etsy + Printful is best for beginners with built-in traffic.',
          ),
          QuizQuestion(
            question: 'What is the most important factor for POD success?',
            options: [
              'Having the cheapest prices',
              'Unique designs in a targeted niche',
              'Selling generic designs to everyone',
              'Only selling t-shirts',
            ],
            correctAnswer: 1,
            explanation: 'Unique designs in a targeted niche attract passionate customers.',
          ),
        ],
      ),

      // Lesson 18: Online Tutoring & Teaching
      Lesson(
        id: '18',
        title: 'Online Tutoring & Teaching: Share Knowledge for Profit',
        summary: 'Transform your expertise into income through online tutoring and teaching. Learn platforms, pricing, and marketing to earn \$2K-10K+ monthly helping students succeed.',
        contentMD: '''# Online Tutoring & Teaching: Share Knowledge for Profit

## Introduction: The Online Education Boom

Online education is a \$400+ billion industry growing 20% annually. Students worldwide need help, and you can earn excellent income sharing your knowledge.

## Understanding Online Tutoring

### Why Online Tutoring Works

**Benefits for Tutors:**
- Work from home
- Set your own rates
- Flexible schedule
- Help students succeed
- Low startup costs

**Benefits for Students:**
- Convenient scheduling
- Access to experts
- Personalized attention
- Affordable rates
- Recorded sessions

### Income Potential

**Beginners (\$15-25/hour)**
- General subjects
- Elementary level
- Group sessions

**Intermediate (\$25-50/hour)**
- Specialized subjects
- High school level
- Test prep basics

**Advanced (\$50-150+/hour)**
- Expert subjects
- College level
- SAT/ACT prep
- Professional exams

## Phase 1: Choosing Your Subject

**High-Demand Subjects:**

**Academic**
- Math (all levels)
- Science (Physics, Chemistry)
- English/Writing
- Foreign languages

**Test Preparation**
- SAT/ACT
- GRE/GMAT
- TOEFL/IELTS
- Professional certifications

**Skills & Hobbies**
- Music lessons
- Coding/Programming
- Art & Design
- Business skills

## Phase 2: Platform Selection

**Tutoring Platforms:**

**Wyzant**
- Large student base
- Set your own rates
- Build reputation
- 25% platform fee

**Tutor.com**
- Steady demand
- Flexible hours
- Fixed rates
- Background check required

**VIPKid**
- Teach English to Chinese students
- \$14-22/hour
- Early morning hours

## Conclusion

Online tutoring rewards patience and expertise.

**Key Takeaways:**
1. Start with subjects you know well
2. Invest in good equipment
3. Build positive reviews
4. Provide personalized attention
5. Focus on student results
        ''',
        estMinutes: 18,
        coinReward: 90,
        category: 'How to Make Money Online',
        tags: ['online-tutoring', 'teaching', 'education', 'remote-work'],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
        quiz: [
          QuizQuestion(
            question: 'What is a typical hourly rate for online tutoring?',
            options: [
              '\$5-10/hour',
              '\$10-20/hour',
              '\$25-75/hour depending on subject and experience',
              '\$100-200/hour for everyone',
            ],
            correctAnswer: 2,
            explanation: 'Typical tutoring rates range from \$25-75/hour depending on subject and expertise.',
          ),
          QuizQuestion(
            question: 'Which platform is best for new online tutors?',
            options: [
              'Only offer in-person tutoring',
              'Wyzant or Tutor.com for built-in students',
              'Start your own website immediately',
              'Wait until you have a teaching degree',
            ],
            correctAnswer: 1,
            explanation: 'Platforms like Wyzant provide access to students actively looking for tutors.',
          ),
          QuizQuestion(
            question: 'What is the key to getting repeat tutoring clients?',
            options: [
              'Being the cheapest tutor available',
              'Results, patience, and personalized attention',
              'Only focusing on test prep',
              'Teaching as many subjects as possible',
            ],
            correctAnswer: 1,
            explanation: 'Results, patience, and personalized attention are key to repeat clients.',
          ),
        ],
      ),

      // Lesson 19: Social Media Management
      Lesson(
        id: '19',
        title: 'Social Media Management: Turn Scrolling Into Income',
        summary: 'Build a lucrative social media management business. Master content creation, engagement strategies, and client management to earn \$2K-8K+ monthly managing brands.',
        contentMD: '''# Social Media Management: Turn Scrolling Into Income

## Introduction: The SMM Opportunity

Businesses need social media presence but lack time and expertise. Social media managers earn \$2K-8K+ monthly per client managing accounts, creating content, and growing audiences.

## Understanding Social Media Management

### What is Social Media Management?

**Core Responsibilities:**
- Content creation and scheduling
- Community engagement
- Analytics and reporting
- Strategy development
- Brand voice maintenance

**Why Businesses Hire SMMs:**
- Time savings
- Expertise in platforms
- Consistent posting
- Better engagement
- Professional content

### Income Potential

**Beginners (\$500-1,000/month per client)**
- Basic posting
- Simple graphics
- 1-2 platforms

**Intermediate (\$1,000-2,500/month per client)**
- Strategic content
- Multiple platforms
- Analytics reporting
- Community management

**Advanced (\$2,500-5,000+/month per client)**
- Full strategy
- Ad management
- Influencer outreach
- Team coordination

## Phase 1: Choosing Your Platforms

**Platform Focus:**

**Instagram**
- Visual content
- Stories & Reels
- Influencer marketing
- Shopping features

**Facebook**
- Community building
- Groups management
- Ads platform
- Local businesses

**LinkedIn**
- B2B marketing
- Professional content
- Networking
- Thought leadership

**TikTok**
- Short-form video
- Viral trends
- Young audience
- Creative content

## Phase 2: Service Packages

**Basic Package (\$500-1,000)**
- 12-15 posts per month
- 1 platform
- Basic graphics
- Monthly report

**Standard Package (\$1,000-2,500)**
- 20-30 posts per month
- 2-3 platforms
- Custom graphics
- Community engagement
- Bi-weekly reports

**Premium Package (\$2,500-5,000+)**
- Daily posting
- All major platforms
- Video content
- Paid ads management
- Weekly strategy calls
- Influencer outreach

## Conclusion

Social media management rewards creativity and consistency.

**Key Takeaways:**
1. Specialize in 2-3 platforms
2. Understand each platform's algorithm
3. Create engaging content
4. Show measurable results
5. Maintain 5-8 clients maximum
        ''',
        estMinutes: 17,
        coinReward: 85,
        category: 'How to Make Money Online',
        tags: ['social-media', 'marketing', 'remote-work', 'digital-marketing'],
        createdAt: DateTime.now().subtract(const Duration(days: 9)),
        updatedAt: DateTime.now(),
        quiz: [
          QuizQuestion(
            question: 'What is typical monthly pricing for social media management?',
            options: [
              '\$100-300/month per client',
              '\$500-3,000/month per client',
              '\$5,000-10,000/month for beginners',
              '\$50/month per client',
            ],
            correctAnswer: 1,
            explanation: 'Social media management typically costs \$500-3,000/month per client.',
          ),
          QuizQuestion(
            question: 'How many clients should you aim for as a solo SMM?',
            options: [
              '1-2 clients maximum',
              '20-30 clients',
              '5-8 clients for sustainable workload',
              '50+ clients',
            ],
            correctAnswer: 2,
            explanation: '5-8 clients is ideal for solo social media managers.',
          ),
          QuizQuestion(
            question: 'What is the most valuable skill for SMM success?',
            options: [
              'Having millions of personal followers',
              'Understanding each platform\'s algorithm and audience behavior',
              'Only knowing how to post photos',
              'Being active 24/7',
            ],
            correctAnswer: 1,
            explanation: 'Understanding platform algorithms and audience behavior is most valuable.',
          ),
        ],
      ),

      // Lesson 20: Passive Income Streams
      Lesson(
        id: '20',
        title: 'Passive Income Streams: Build Wealth While You Sleep',
        summary: 'Create multiple passive income streams that generate money 24/7. Learn proven strategies for digital products, investments, and automation to earn \$3K-15K+ monthly.',
        contentMD: '''# Passive Income Streams: Build Wealth While You Sleep

## Introduction: The Passive Income Dream

True passive income requires upfront work but pays dividends forever. Build assets that generate income 24/7 with minimal maintenance.

## Understanding Passive Income

### What is Passive Income?

**Definition:**
Income that continues to flow after the initial work is complete, requiring minimal ongoing effort.

**Common Myths:**
- It's completely effortless
- Get rich quick schemes
- No initial work required
- Guaranteed returns

**Reality:**
- Requires significant upfront effort
- Takes time to build (6-24 months)
- Needs occasional maintenance
- Multiple streams recommended

### Income Streams Overview

**Digital Products**
- Online courses
- Ebooks
- Templates
- Software/apps

**Investments**
- Dividend stocks
- Real estate
- Index funds
- Bonds

**Content Monetization**
- YouTube ads
- Blog advertising
- Podcast sponsorships
- Affiliate marketing

## Phase 1: Digital Products

**Online Courses (\$1,000-10,000+/month)**

**Creating Your Course:**
1. Validate demand
2. Pre-sell before creating
3. Record content
4. Build landing page
5. Launch and market

**Platforms:**
- Teachable
- Gumroad
- Udemy
- Skillshare

**Ebooks (\$500-3,000/month)**

**Self-Publishing:**
- Amazon KDP
- Gumroad
- Your website
- Bundle with courses

## Phase 2: Investment Income

**Dividend Stocks**
- 2-6% annual yield
- Quarterly payments
- Compound returns
- Long-term growth

**Real Estate**
- Rental properties
- REITs (Real Estate Investment Trusts)
- House flipping
- Airbnb hosting

**Index Funds**
- S&P 500 index
- Total market funds
- 7-10% average return
- Dollar-cost averaging

## Phase 3: Content Monetization

**YouTube Channel**
- Ad revenue: \$1-5 per 1,000 views
- Requires: 1,000 subs, 4,000 watch hours
- Evergreen content compounds
- Multiple revenue streams

**Blog/Website**
- Display ads
- Affiliate marketing
- Sponsored content
- Digital products

## Conclusion

Build passive income sequentially—focus on one stream until successful.

**Key Takeaways:**
1. Start with ONE income stream
2. Digital products have lowest barrier
3. Investments require capital
4. Consistency is critical
5. Diversify over time (3-5 streams)
6. Reinvest profits for growth
7. Play the long game (12-24 months)
        ''',
        estMinutes: 21,
        coinReward: 105,
        category: 'How to Make Money Online',
        tags: ['passive-income', 'investing', 'digital-products', 'wealth-building'],
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now(),
        quiz: [
          QuizQuestion(
            question: 'What is true passive income?',
            options: [
              'Income that requires no initial work',
              'Income that generates 24/7 after upfront effort with minimal maintenance',
              'Any freelance work',
              'Only inheritance money',
            ],
            correctAnswer: 1,
            explanation: 'True passive income requires significant upfront work but then generates income with minimal maintenance.',
          ),
          QuizQuestion(
            question: 'Which passive income stream can be started with the lowest investment?',
            options: [
              'Real estate investing',
              'Stock market investing',
              'Digital products (ebooks, courses)',
              'Opening a franchise',
            ],
            correctAnswer: 2,
            explanation: 'Digital products can be created with \$0-100 investment.',
          ),
          QuizQuestion(
            question: 'How many passive income streams should you aim to build?',
            options: [
              'Focus on 1 until it\'s successful, then add more',
              'Start 10-20 simultaneously',
              'Passive income doesn\'t work',
              'Only focus on one forever',
            ],
            correctAnswer: 0,
            explanation: 'Focus on ONE stream until successful, then add more. Build sequentially: 1, then 2, then 3-5 total.',
          ),
        ],
      ),
    ];

    // Initialize sample transactions
    _transactions = [
      Transaction(
        id: '1',
        title: 'Welcome Bonus',
        amount: 1000,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: 'earned',
      ),
    ];
  }

  void addCoins(int amount, String source) async {
    _coins += amount;
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: source,
      amount: amount,
      timestamp: DateTime.now(),
      type: 'earned',
    );
    _transactions.insert(0, transaction);

    // Try to sync with backend
    try {
      await ApiService.recordEarning(source, amount);
    } catch (e) {
      print('Failed to sync earning with backend: $e');
    }

    _saveData();
    notifyListeners();
  }

  void spendCoins(int amount, String reason) {
    if (_coins >= amount) {
      _coins -= amount;
      _transactions.insert(
        0,
        Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: reason,
          amount: -amount,
          timestamp: DateTime.now(),
          type: 'spent',
        ),
      );
      _saveData();
      notifyListeners();
    }
  }

  Future<void> completeLesson(String lessonId) async {
    final index = _lessons.indexWhere((lesson) => lesson.id == lessonId);
    if (index != -1 && !_lessons[index].isCompleted) {
      // Update local state first
      _lessons[index] = _lessons[index].copyWith(isCompleted: true);
      addCoins(
        15,
        'Lesson Completed',
      ); // 15 coins for lesson completion as per README

      // Sync with backend
      try {
        final result = await ApiService.completeLesson(lessonId);
        if (result['success'] == true) {
          print('Lesson completion synced with backend');
        } else {
          print(
            'Failed to sync lesson completion with backend: ${result['message']}',
          );
        }
      } catch (e) {
        print('Error syncing lesson completion: $e');
      }

      _saveData();
      notifyListeners();
    }
  }

  Future<bool> watchAd() async {
    try {
      final reward = await AdService.instance.showRewardedAd();
      if (reward != null) {
        addCoins(15, 'Ad Watched'); // 15 coins for rewarded video as per README
        return true;
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error showing ad: $e');
      }
      return false;
    }
  }

  // Show ad when starting a lesson
  Future<bool> showLessonAd() async {
    try {
      final reward = await AdService.instance.showRewardedAd();
      if (reward != null) {
        addCoins(10, 'Lesson Ad Bonus'); // 10 coins for lesson ad bonus
        return true;
      }
      return false;
    } catch (e) {
      print('Error showing lesson ad: $e');
      return false;
    }
  }

  // Show ad on daily login
  Future<bool> showDailyLoginAd() async {
    try {
      final reward = await AdService.instance.showRewardedAd();
      if (reward != null) {
        addCoins(
          10,
          'Daily Login Ad Bonus',
        ); // 10 coins for daily login ad bonus
        return true;
      }
      return false;
    } catch (e) {
      print('Error showing daily login ad: $e');
      return false;
    }
  }

  // Show ad when navigating between screens
  Future<bool> showNavigationAd() async {
    try {
      final adShown = await AdService.instance.showInterstitialAd();
      if (adShown) {
        addCoins(5, 'Navigation Ad Bonus'); // 5 coins for navigation ad bonus
      }
      return adShown;
    } catch (e) {
      print('Error showing navigation ad: $e');
      return false;
    }
  }

  // Show ad when completing daily challenge
  Future<bool> showDailyChallengeAd() async {
    try {
      final reward = await AdService.instance.showRewardedAd();
      if (reward != null) {
        addCoins(
          15,
          'Daily Challenge Ad Bonus',
        ); // 15 coins for daily challenge ad bonus
        return true;
      }
      return false;
    } catch (e) {
      print('Error showing daily challenge ad: $e');
      return false;
    }
  }

  // Show ad when viewing profile
  Future<bool> showProfileAd() async {
    try {
      final adShown = await AdService.instance.showInterstitialAd();
      if (adShown) {
        addCoins(5, 'Profile Ad Bonus'); // 5 coins for profile ad bonus
      }
      return adShown;
    } catch (e) {
      print('Error showing profile ad: $e');
      return false;
    }
  }

  // Show ad before quiz
  Future<bool> showQuizAd() async {
    try {
      final reward = await AdService.instance.showRewardedAd();
      if (reward != null) {
        addCoins(10, 'Quiz Ad Bonus'); // 10 coins for quiz ad bonus
        return true;
      }
      return false;
    } catch (e) {
      print('Error showing quiz ad: $e');
      return false;
    }
  }

  // Show ad when requesting payout
  Future<bool> showPayoutAd() async {
    try {
      final reward = await AdService.instance.showRewardedAd();
      if (reward != null) {
        addCoins(
          20,
          'Payout Ad Bonus',
        ); // 20 coins for payout ad bonus (higher value for payout)
        return true;
      }
      return false;
    } catch (e) {
      print('Error showing payout ad: $e');
      return false;
    }
  }

  Future<void> _saveData() async {
    await StorageService.saveCoins(_coins);
    await StorageService.saveLessons(_lessons);
    await StorageService.saveTransactions(_transactions);
  }

  // Check if daily login is available
  bool get canClaimDailyLogin {
    if (_lastDailyLogin == null) return true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastLogin = DateTime(
      _lastDailyLogin!.year,
      _lastDailyLogin!.month,
      _lastDailyLogin!.day,
    );
    return lastLogin.isBefore(today);
  }

  // Daily login with rewarded ad requirement
  Future<Map<String, dynamic>> claimDailyLogin() async {
    // Check if already claimed today
    if (!canClaimDailyLogin) {
      return {
        'success': false,
        'message': 'Daily login already claimed today. Come back tomorrow!',
      };
    }

    // Show rewarded ad first
    try {
      final reward = await AdService.instance.showRewardedAd();
      if (reward != null) {
        // Ad watched successfully, give coins
        addCoins(5, 'Daily Login'); // 5 coins for daily login as per README

        // Update last daily login date
        _lastDailyLogin = DateTime.now();
        await StorageService.saveLastDailyLogin(_lastDailyLogin!);
        await _saveData();

        // Update learning streak
        _updateLearningStreak();

        notifyListeners();

        return {
          'success': true,
          'message': 'Daily login bonus claimed! +5 coins',
          'coins': 5,
        };
      } else {
        return {
          'success': false,
          'message': 'Please watch the ad to claim your daily login bonus.',
        };
      }
    } catch (e) {
      print('Error showing daily login ad: $e');
      return {
        'success': false,
        'message': 'Ad not available. Please try again later.',
      };
    }
  }

  // Legacy method for backward compatibility (deprecated)
  @deprecated
  void dailyLogin() {
    addCoins(5, 'Daily Login'); // 5 coins for daily login as per README
  }

  // Update learning streak
  void _updateLearningStreak() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastStreakDate == null) {
      _learningStreak = 1;
      _lastStreakDate = today;
    } else {
      final lastStreak = DateTime(
        _lastStreakDate!.year,
        _lastStreakDate!.month,
        _lastStreakDate!.day,
      );

      final daysDifference = today.difference(lastStreak).inDays;

      if (daysDifference == 0) {
        // Same day, no change
        return;
      } else if (daysDifference == 1) {
        // Consecutive day, increment streak
        _learningStreak++;
        _lastStreakDate = today;
      } else {
        // Streak broken, reset to 1
        _learningStreak = 1;
        _lastStreakDate = today;
      }
    }

    // Save locally
    StorageService.saveLearningStreak(_learningStreak);
    StorageService.saveLastStreakDate(_lastStreakDate!);

    // Sync with backend if user is authenticated
    if (_isAuthenticated && _isOnline) {
      try {
        // Backend sync can be implemented when backend endpoint is available
        // Example: await ApiService.updateLearningStreak(_learningStreak, _lastStreakDate!);
        if (kDebugMode) {
          print('Learning streak synced: $_learningStreak days');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Failed to sync learning streak with backend: $e');
        }
      }
    }
  }

  void completeQuiz() {
    addCoins(
      20,
      'Quiz Completed',
    ); // 20 coins for quiz completion as per README
  }

  // Request payout
  Future<Map<String, dynamic>> requestPayout(String mobileNumber) async {
    try {
      // Check minimum payout requirement
      if (_coins < AppConstants.MIN_PAYOUT_COINS) {
        return {
          'success': false,
          'message':
              'Minimum payout is ${AppConstants.MIN_PAYOUT_COINS} coins (${AppConstants.formatCashShort(AppConstants.MIN_PAYOUT_CASH)})',
        };
      }

      // Convert coins to USD (assuming 1000 coins = $1)
      final amountUsd = _coins / 1000.0;

      final result = await ApiService.requestPayout(mobileNumber, _coins, amountUsd);
      if (result['success'] == true) {
        // Reset coins after successful payout request
        _coins = 0;
        _transactions.insert(
          0,
          Transaction(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Payout Requested',
            amount: -_coins,
            timestamp: DateTime.now(),
            type: 'spent',
          ),
        );
        _saveData();
        notifyListeners();
      }
      return result;
    } catch (e) {
      print('Error requesting payout: $e');
      return {'success': false, 'message': 'Failed to request payout: $e'};
    }
  }

  // Get payout history
  Future<List<Map<String, dynamic>>> getPayoutHistory() async {
    try {
      return await ApiService.getPayoutHistory();
    } catch (e) {
      print('Error loading payout history: $e');
      return [];
    }
  }

  // Submit quiz results to backend
  Future<Map<String, dynamic>> submitQuizToBackend(
    String lessonId,
    List<int> answers,
    int timeSpent,
  ) async {
    try {
      final result = await ApiService.submitQuiz(lessonId, answers, timeSpent);

      if (result['success'] == true || result['passed'] == true) {
        // Add coins if quiz was passed
        final coinsEarned = result['coinsEarned'] ?? 0;
        if (coinsEarned > 0) {
          addCoins(coinsEarned, 'Quiz Completed');
        }
      }

      return result;
    } catch (e) {
      print('Error submitting quiz to backend: $e');
      return {'success': false, 'message': 'Failed to submit quiz: $e'};
    }
  }

  // Sync data with backend
  Future<void> syncWithBackend() async {
    try {
      print('Syncing with backend...');

      // Sync earnings
      for (final transaction in _transactions) {
        if (transaction.type == 'earned') {
          await ApiService.recordEarning(transaction.title, transaction.amount);
        }
      }

      // Load latest data from backend
      await _loadData();

      print('Backend sync completed');
    } catch (e) {
      print('Error syncing with backend: $e');
    }
  }

  // Check if daily reset is needed
  Future<void> _checkDailyReset() async {
    try {
      // Check with backend first
      final progressData = await ApiService.getUserProgress();
      final isNewDay = progressData['isNewDay'] ?? false;

      if (isNewDay) {
        print('Performing daily reset via backend...');
        final resetResult = await ApiService.performDailyReset();

        if (resetResult['success'] == true) {
          // Reset local lessons
          for (int i = 0; i < _lessons.length; i++) {
            _lessons[i] = _lessons[i].copyWith(isCompleted: false);
          }

          // Add daily reset bonus
          addCoins(
            5,
            'Daily Reset Bonus',
          ); // 5 coins for daily reset bonus as per README

          // Update local reset date
          final today = DateTime.now();
          final todayDate = DateTime(today.year, today.month, today.day);
          await StorageService.saveLastResetDate(todayDate);
          _lastResetDate = todayDate;

          print('Daily reset completed via backend');
        } else {
          print('Backend daily reset failed, using local reset');
          await _performLocalDailyReset();
        }
      } else {
        // Load last reset date from storage for local fallback
        final lastReset = await StorageService.loadLastResetDate();
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        if (lastReset == null || lastReset.isBefore(today)) {
          print('Performing local daily reset...');
          await _performLocalDailyReset();
        }
      }
    } catch (e) {
      print('Error checking daily reset: $e');
      // Fallback to local reset
      await _performLocalDailyReset();
    }
  }

  // Perform local daily reset of lessons
  Future<void> _performLocalDailyReset() async {
    // Reset all lessons to incomplete
    for (int i = 0; i < _lessons.length; i++) {
      _lessons[i] = _lessons[i].copyWith(isCompleted: false);
    }

    // Add daily reset bonus
    addCoins(
      5,
      'Daily Reset Bonus',
    ); // 5 coins for daily reset bonus as per README

    // Update local reset date
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    await StorageService.saveLastResetDate(todayDate);
    _lastResetDate = todayDate;

    // Save updated data
    await _saveData();

    print('Local daily reset completed - all lessons reset, +50 coins bonus');
    notifyListeners();
  }

  // Get daily reset status
  bool get isNewDay {
    if (_lastResetDate == null) return true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _lastResetDate!.isBefore(today);
  }

  // Get days since last reset
  int get daysSinceLastReset {
    if (_lastResetDate == null) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.difference(_lastResetDate!).inDays;
  }
}
