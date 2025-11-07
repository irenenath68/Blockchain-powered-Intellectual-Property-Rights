import fs from 'fs';
const required = [
  'contracts/charity-donation-tracker.clar',
  'deployments/default.simnet-plan.yaml',
  'settings/Simnet.toml',
  '.github/workflows/ci.yml'
];
for (const p of required) {
  if (!fs.existsSync(p)) {
    console.error('Missing required file:', p);
    process.exit(1);
  }
}
console.log('npm test passed: required files present');
