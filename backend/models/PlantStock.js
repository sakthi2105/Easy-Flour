const mongoose = require('mongoose');

const plantStockSchema = mongoose.Schema({
  admin: { type: mongoose.Schema.Types.ObjectId, required: true, ref: 'Admin' },
  plantKg: { type: Number, required: true },
  pricePerKg: { type: Number, required: true },
  totalAmount: { type: Number, required: true },
  date: { type: Date, required: true, default: Date.now }
}, { timestamps: true });

module.exports = mongoose.model('PlantStock', plantStockSchema);