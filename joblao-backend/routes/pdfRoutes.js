const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const router = express.Router();
const pdfController = require('../controllers/pdfController');

// 업로드 디렉토리 생성 (없을 경우)
const uploadDir = path.join(__dirname, '../uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir);
}

// multer 설정
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const ext = path.extname(file.originalname);
    cb(null, 'pdf_' + Date.now() + ext);
  },
});

const fileFilter = (req, file, cb) => {
  if (file.mimetype === 'application/pdf') {
    cb(null, true);
  } else {
   console.log('file.mimetype:', file.mimetype); // 로그로 userId 확인
    cb(new Error('PDF 파일만 업로드 가능합니다.'));
  }
};

const upload = multer({ storage, fileFilter });

router.post('/upload-pdf', upload.single('pdf'), pdfController.uploadPdf);

module.exports = router;
