const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'ehlee3275@gmail.com',
    pass: 'lfla qfrq oyrl etfw',
  },
});

module.exports = async function sendVerificationEmail(to, code) {
  await transporter.sendMail({
    from: '"My App" <ehlee3275@gmail.com>',
    to,
    subject: '이메일 인증 코드',
    text: `인증코드: ${code} (3분 내에 입력하세요)`,
  });
};
