import express from 'express';
import multer from 'multer';
import { uploadModel } from './controllers/modelController.js';

const router = express.Router();
const upload = multer(); // Memory storage here

router.post('/upload-model', upload.single('modelFile'), uploadModel);

export default router;
