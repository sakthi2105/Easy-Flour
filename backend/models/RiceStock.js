const mongoose = require('mongoose');

const riceStockSchema = mongoose.Schema({
  customerName: { type: String, required: true },
  riceKg: { type: Number, required: true },
  pricePerKg: { type: Number, required: true },
  totalAmount: { type: Number, required: true },
  date: { type: Date, required: true, default: Date.now }
}, { timestamps: true });

module.exports = mongoose.model('RiceStock', riceStockSchema);