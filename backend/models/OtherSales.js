const mongoose = require('mongoose');

const otherSalesSchema = mongoose.Schema({
  pocketCount: { type: Number, required: true },
  pocketPrice: { type: Number, required: true },
  totalAmount: { type: Number, required: true },
  pendingAmount: { type: Number, required: true, default: 0 },
  date: { type: Date, required: true, default: Date.now }
}, { timestamps: true });

module.exports = mongoose.model('OtherSales', otherSalesSchema);