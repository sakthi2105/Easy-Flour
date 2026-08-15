const fs = require('fs');
const path = require('path');

const modelsDir = path.join(__dirname, 'backend', 'models');

if (!fs.existsSync(modelsDir)){
    fs.mkdirSync(modelsDir, { recursive: true });
}

const models = {
  'Admin.js': `const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const adminSchema = mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true }
}, { timestamps: true });

adminSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
});

adminSchema.methods.matchPassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

module.exports = mongoose.model('Admin', adminSchema);`,

  'RiceStock.js': `const mongoose = require('mongoose');

const riceStockSchema = mongoose.Schema({
  customerName: { type: String, required: true },
  riceKg: { type: Number, required: true },
  pricePerKg: { type: Number, required: true },
  totalAmount: { type: Number, required: true },
  date: { type: Date, required: true, default: Date.now }
}, { timestamps: true });

module.exports = mongoose.model('RiceStock', riceStockSchema);`,

  'PlantStock.js': `const mongoose = require('mongoose');

const plantStockSchema = mongoose.Schema({
  plantKg: { type: Number, required: true },
  pricePerKg: { type: Number, required: true },
  totalAmount: { type: Number, required: true },
  date: { type: Date, required: true, default: Date.now }
}, { timestamps: true });

module.exports = mongoose.model('PlantStock', plantStockSchema);`,

  'Production.js': `const mongoose = require('mongoose');

const productionSchema = mongoose.Schema({
  riceUsedKg: { type: Number, required: true },
  plantUsedKg: { type: Number, required: true },
  flourProducedKg: { type: Number, required: true },
  productionDate: { type: Date, required: true, default: Date.now },
  remarks: { type: String }
}, { timestamps: true });

module.exports = mongoose.model('Production', productionSchema);`,

  'ShopSales.js': `const mongoose = require('mongoose');

const shopSalesSchema = mongoose.Schema({
  shopName: { type: String, required: true },
  pocketCount: { type: Number, required: true },
  pocketPrice: { type: Number, required: true },
  totalAmount: { type: Number, required: true },
  collectionReceived: { type: Number, required: true, default: 0 },
  pendingAmount: { type: Number, required: true },
  pendingCollectionDate: { type: Date },
  salesDate: { type: Date, required: true, default: Date.now }
}, { timestamps: true });

module.exports = mongoose.model('ShopSales', shopSalesSchema);`,

  'OtherSales.js': `const mongoose = require('mongoose');

const otherSalesSchema = mongoose.Schema({
  pocketCount: { type: Number, required: true },
  pocketPrice: { type: Number, required: true },
  totalAmount: { type: Number, required: true },
  pendingAmount: { type: Number, required: true, default: 0 },
  date: { type: Date, required: true, default: Date.now }
}, { timestamps: true });

module.exports = mongoose.model('OtherSales', otherSalesSchema);`,

  'Expense.js': `const mongoose = require('mongoose');

const expenseSchema = mongoose.Schema({
  expenseName: { type: String, required: true },
  amount: { type: Number, required: true },
  date: { type: Date, required: true, default: Date.now }
}, { timestamps: true });

module.exports = mongoose.model('Expense', expenseSchema);`,

  'StockSummary.js': `const mongoose = require('mongoose');

const stockSummarySchema = mongoose.Schema({
  totalRiceKg: { type: Number, required: true, default: 0 },
  totalPlantKg: { type: Number, required: true, default: 0 },
  totalFlourKg: { type: Number, required: true, default: 0 }
}, { timestamps: true });

module.exports = mongoose.model('StockSummary', stockSummarySchema);`
};

for (const [filename, content] of Object.entries(models)) {
  fs.writeFileSync(path.join(modelsDir, filename), content);
  console.log(\`Created \${filename}\`);
}
