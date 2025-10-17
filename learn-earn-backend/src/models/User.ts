import mongoose, { Document, Schema } from 'mongoose';

export interface IReadingSession {
  startedAt: Date;
  endedAt?: Date;
  durationSeconds: number;
}

export interface ILessonProgress {
  lessonId: string;
  scrollPosition: number; // 0-100 percentage
  timeSpentSeconds: number;
  lastReadAt: Date;
  completedAt?: Date;
  isCompleted: boolean;
  readingSessions: IReadingSession[];
}

export interface IUser extends Document {
  deviceId: string;
  pubKey: string;
  mmHash?: string;
  numberLockedUntil?: Date;
  createdAt: Date;
  isEmulator: boolean;
  lastActiveAt: Date;
  lastDailyReset?: Date;
  completedLessons: string[]; // Keep for backward compatibility
  dailyResetCount: number;
  lessonProgress: ILessonProgress[]; // New detailed progress tracking
}

const ReadingSessionSchema = new Schema<IReadingSession>({
  startedAt: { type: Date, required: true },
  endedAt: { type: Date },
  durationSeconds: { type: Number, required: true, default: 0 }
}, { _id: false });

const LessonProgressSchema = new Schema<ILessonProgress>({
  lessonId: { type: String, required: true, index: true },
  scrollPosition: { type: Number, required: true, default: 0, min: 0, max: 100 },
  timeSpentSeconds: { type: Number, required: true, default: 0 },
  lastReadAt: { type: Date, required: true, default: Date.now },
  completedAt: { type: Date },
  isCompleted: { type: Boolean, default: false },
  readingSessions: { type: [ReadingSessionSchema], default: [] }
}, { _id: false });

const UserSchema = new Schema<IUser>({
  deviceId: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  pubKey: {
    type: String,
    required: true
  },
  mmHash: {
    type: String,
    sparse: true
  },
  numberLockedUntil: {
    type: Date
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  isEmulator: {
    type: Boolean,
    default: false
  },
  lastActiveAt: {
    type: Date,
    default: Date.now
  },
  lastDailyReset: {
    type: Date
  },
  completedLessons: {
    type: [String],
    default: []
  },
  dailyResetCount: {
    type: Number,
    default: 0
  },
  lessonProgress: {
    type: [LessonProgressSchema],
    default: []
  }
});

export default mongoose.model<IUser>('User', UserSchema);
