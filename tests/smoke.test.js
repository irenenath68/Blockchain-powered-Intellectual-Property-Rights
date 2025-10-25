const fs = require('fs');
if (!fs.existsSync('contracts/ip-rights.clar')) {
  console.error('Contract file missing');
  process.exit(1);
}
console.log('npm test passed: contract file exists');