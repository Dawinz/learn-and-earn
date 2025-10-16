import mongoose, { Document, Schema } from 'mongoose';

export interface IVersion extends Document {
  // Minimum required version
  minimumVersion: string;
  minimumBuildNumber: number;

  // Latest available version
  latestVersion: string;
  latestBuildNumber: number;

  // Update settings
  forceUpdate: boolean;
  updateMessage: string;
  updateTitle: string;

  // Download links
  androidDownloadUrl: string;
  iosDownloadUrl: string;

  // Maintenance mode
  maintenanceMode: boolean;
  maintenanceMessage: string;

  // Feature flags
  features: {
    adsEnabled: boolean;
    notificationsEnabled: boolean;
    payoutsEnabled: boolean;
    newFeatures: string[];
  };

  // Metadata
  lastUpdated: Date;
  updatedBy?: string;
}

const VersionSchema = new Schema<IVersion>({
  minimumVersion: {
    type: String,
    required: true,
    default: '1.0.0'
  },
  minimumBuildNumber: {
    type: Number,
    required: true,
    default: 1
  },
  latestVersion: {
    type: String,
    required: true,
    default: '1.0.0'
  },
  latestBuildNumber: {
    type: Number,
    required: true,
    default: 1
  },
  forceUpdate: {
    type: Boolean,
    required: true,
    default: false
  },
  updateMessage: {
    type: String,
    required: true,
    default: 'A new version is available with bug fixes and improvements.'
  },
  updateTitle: {
    type: String,
    required: true,
    default: 'Update Available'
  },
  androidDownloadUrl: {
    type: String,
    required: true,
    default: 'https://play.google.com/store/apps/details?id=com.example.learn_earn_mobile'
  },
  iosDownloadUrl: {
    type: String,
    required: true,
    default: 'https://apps.apple.com/app/learn-earn/id123456789'
  },
  maintenanceMode: {
    type: Boolean,
    required: true,
    default: false
  },
  maintenanceMessage: {
    type: String,
    required: true,
    default: 'The app is currently under maintenance. Please try again later.'
  },
  features: {
    adsEnabled: {
      type: Boolean,
      default: true
    },
    notificationsEnabled: {
      type: Boolean,
      default: true
    },
    payoutsEnabled: {
      type: Boolean,
      default: true
    },
    newFeatures: [{
      type: String
    }]
  },
  lastUpdated: {
    type: Date,
    default: Date.now
  },
  updatedBy: {
    type: String
  }
}, {
  timestamps: true
});

// Ensure only one version document exists
VersionSchema.index({}, { unique: true });

export default mongoose.model<IVersion>('Version', VersionSchema);
