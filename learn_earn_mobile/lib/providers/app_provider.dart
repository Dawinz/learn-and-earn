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
  User? _user;
  bool _isAuthenticated = false;
  bool _isOnline = true;

  // Getters
  int get coins => _coins;
  List<Lesson> get lessons => _lessons;
  List<Transaction> get transactions => _transactions;
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

  void dailyLogin() {
    addCoins(5, 'Daily Login'); // 5 coins for daily login as per README
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

      final result = await ApiService.requestPayout(mobileNumber, _coins);
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
