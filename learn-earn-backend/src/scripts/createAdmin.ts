import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';
import dotenv from 'dotenv';
import Admin from '../models/Admin';

// Load environment variables
dotenv.config();

/**
 * Script to create an admin user
 * Usage: ts-node src/scripts/createAdmin.ts <username> <email> <password> [role]
 */
async function createAdmin() {
  try {
    const args = process.argv.slice(2);

    if (args.length < 3) {
      console.error('Usage: ts-node src/scripts/createAdmin.ts <username> <email> <password> [role]');
      console.error('Role can be: admin or super_admin (default: admin)');
      process.exit(1);
    }

    const [username, email, password, role = 'admin'] = args;

    // Validate role
    if (role !== 'admin' && role !== 'super_admin') {
      console.error('Role must be either "admin" or "super_admin"');
      process.exit(1);
    }

    // Connect to MongoDB
    const mongoUrl = process.env.MONGO_URL || 'mongodb://localhost:27017/learn_earn';
    await mongoose.connect(mongoUrl);
    console.log('Connected to MongoDB');

    // Check if admin already exists
    const existingAdmin = await Admin.findOne({ $or: [{ username }, { email }] });
    if (existingAdmin) {
      console.error(`Admin already exists with username "${existingAdmin.username}" or email "${existingAdmin.email}"`);
      process.exit(1);
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create admin
    const admin = await Admin.create({
      username,
      email,
      password: hashedPassword,
      role,
      isActive: true
    });

    console.log('\n✅ Admin user created successfully!');
    console.log('--------------------------------');
    console.log(`Username: ${admin.username}`);
    console.log(`Email: ${admin.email}`);
    console.log(`Role: ${admin.role}`);
    console.log(`ID: ${admin._id}`);
    console.log('--------------------------------\n');

    process.exit(0);
  } catch (error) {
    console.error('Error creating admin:', error);
    process.exit(1);
  }
}

createAdmin();
