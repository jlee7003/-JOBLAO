const path = require('path');

exports.uploadPdf = (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'PDF 파일이 필요합니다.' });
    }

    const pdfUrl = `/uploads/${req.file.filename}`;

    res.status(200).json({
      message: '업로드 성공',
      pdf_url: pdfUrl,
    });
  } catch (error) {
    console.error('업로드 에러:', error);
    res.status(500).json({ message: '서버 오류가 발생했습니다.' });
  }
};
