console.log("Hello, world!");

const fs = require('fs');
const quotePath = '/dev/attestation/quote';

fs.readFile(quotePath, (err, data) => {
  if (err) {
    console.error(`Error reading ${quotePath}:`, err);
    return;
  }
  console.log("Attestation quote (hex):", data.toString('hex'));
});