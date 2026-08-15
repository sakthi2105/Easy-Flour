const mongoose = require('mongoose');

const stockSummarySchema = mongoose.Schema({
  totalRiceKg: { type: Number, required: true, default: 0 },
  totalPlantKg: { type: Number, required: true, default: 0 },
  totalFlourKg: { type: Number, required: true, default: 0 }
}, { timestamps: true });

module.exports = mongoose.model('StockSummary', stockSummarySchema);
