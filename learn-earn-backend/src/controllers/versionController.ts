import { Response } from 'express';
import Version from '../models/Version';

/**
 * Get app version requirements
 */
export async function getVersionInfo(req: any, res: Response) {
  try {
    // Get version info from database, or create default if doesn't exist
    let versionInfo = await Version.findOne();

    if (!versionInfo) {
      // Create default version info
      versionInfo = await Version.create({
        minimumVersion: '1.0.0',
        minimumBuildNumber: 1,
        latestVersion: '1.0.0',
        latestBuildNumber: 1,
        forceUpdate: false,
        updateMessage: 'A new version is available with bug fixes and improvements.',
        updateTitle: 'Update Available',
        androidDownloadUrl: 'https://play.google.com/store/apps/details?id=com.example.learn_earn_mobile',
        iosDownloadUrl: 'https://apps.apple.com/app/learn-earn/id123456789',
        maintenanceMode: false,
        maintenanceMessage: 'The app is currently under maintenance. Please try again later.',
        features: {
          adsEnabled: true,
          notificationsEnabled: true,
          payoutsEnabled: true,
          newFeatures: []
        }
      });
    }

    res.json({
      success: true,
      data: {
        minimumVersion: versionInfo.minimumVersion,
        minimumBuildNumber: versionInfo.minimumBuildNumber,
        latestVersion: versionInfo.latestVersion,
        latestBuildNumber: versionInfo.latestBuildNumber,
        forceUpdate: versionInfo.forceUpdate,
        updateMessage: versionInfo.updateMessage,
        updateTitle: versionInfo.updateTitle,
        androidDownloadUrl: versionInfo.androidDownloadUrl,
        iosDownloadUrl: versionInfo.iosDownloadUrl,
        maintenanceMode: versionInfo.maintenanceMode,
        maintenanceMessage: versionInfo.maintenanceMessage,
        features: versionInfo.features
      }
    });
  } catch (error) {
    console.error('Get version info error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get version info'
    });
  }
}

/**
 * Update version requirements (admin only)
 */
export async function updateVersionInfo(req: any, res: Response) {
  try {
    const {
      minimumVersion,
      minimumBuildNumber,
      latestVersion,
      latestBuildNumber,
      forceUpdate,
      updateMessage,
      updateTitle,
      androidDownloadUrl,
      iosDownloadUrl,
      maintenanceMode,
      maintenanceMessage,
      features
    } = req.body;

    // Update or create version info
    const updateData: any = {
      lastUpdated: new Date(),
      updatedBy: req.user?.username || 'admin'
    };

    if (minimumVersion !== undefined) updateData.minimumVersion = minimumVersion;
    if (minimumBuildNumber !== undefined) updateData.minimumBuildNumber = minimumBuildNumber;
    if (latestVersion !== undefined) updateData.latestVersion = latestVersion;
    if (latestBuildNumber !== undefined) updateData.latestBuildNumber = latestBuildNumber;
    if (forceUpdate !== undefined) updateData.forceUpdate = forceUpdate;
    if (updateMessage !== undefined) updateData.updateMessage = updateMessage;
    if (updateTitle !== undefined) updateData.updateTitle = updateTitle;
    if (androidDownloadUrl !== undefined) updateData.androidDownloadUrl = androidDownloadUrl;
    if (iosDownloadUrl !== undefined) updateData.iosDownloadUrl = iosDownloadUrl;
    if (maintenanceMode !== undefined) updateData.maintenanceMode = maintenanceMode;
    if (maintenanceMessage !== undefined) updateData.maintenanceMessage = maintenanceMessage;
    if (features !== undefined) updateData.features = features;

    const versionInfo = await Version.findOneAndUpdate(
      {},
      updateData,
      { upsert: true, new: true }
    );

    console.log('Version info updated:', updateData);

    res.json({
      success: true,
      message: 'Version info updated successfully',
      data: versionInfo
    });
  } catch (error) {
    console.error('Update version info error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update version info'
    });
  }
}
