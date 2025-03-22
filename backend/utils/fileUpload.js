const AWS = require('aws-sdk');
const { v4: uuidv4 } = require('uuid');
require('dotenv').config();

// Configure AWS S3
const s3 = new AWS.S3({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION || 'us-east-1'
});

const BUCKET_NAME = process.env.S3_BUCKET_NAME || 'velociti-app-uploads';

/**
 * Upload a file to S3 bucket
 * @param {Object} file - The file object from multer
 * @returns {Promise<string>} - URL of the uploaded file
 */
const uploadToStorage = async (file) => {
  try {
    // If no AWS credentials are configured, use a mock URL for development
    if (!process.env.AWS_ACCESS_KEY_ID || !process.env.AWS_SECRET_ACCESS_KEY) {
      console.warn('AWS credentials not found, returning mock image URL');
      return `https://cdn-icons-png.flaticon.com/128/456/456212.png`;
    }
    
    // Generate a unique filename
    const fileExtension = file.originalname.split('.').pop();
    const fileName = `${uuidv4()}.${fileExtension}`;
    
    // Set the S3 parameters
    const params = {
      Bucket: BUCKET_NAME,
      Key: `profiles/${fileName}`,
      Body: file.buffer,
      ContentType: file.mimetype,
      ACL: 'public-read'
    };
    
    // Upload to S3
    const uploaded = await s3.upload(params).promise();
    
    return uploaded.Location;
  } catch (error) {
    console.error('Error uploading file:', error);
    throw new Error('File upload failed');
  }
};

/**
 * Delete a file from S3 bucket
 * @param {string} fileUrl - URL of the file to delete
 * @returns {Promise<boolean>} - Success status
 */
const deleteFromStorage = async (fileUrl) => {
  try {
    // If no AWS credentials are configured, just return success for development
    if (!process.env.AWS_ACCESS_KEY_ID || !process.env.AWS_SECRET_ACCESS_KEY) {
      console.warn('AWS credentials not found, skipping delete operation');
      return true;
    }
    
    // Extract the key from the URL
    const key = fileUrl.split(`${BUCKET_NAME}/`)[1];
    
    if (!key) {
      throw new Error('Invalid file URL');
    }
    
    // Set the S3 parameters
    const params = {
      Bucket: BUCKET_NAME,
      Key: key
    };
    
    // Delete from S3
    await s3.deleteObject(params).promise();
    
    return true;
  } catch (error) {
    console.error('Error deleting file:', error);
    throw new Error('File deletion failed');
  }
};

module.exports = {
  uploadToStorage,
  deleteFromStorage
};