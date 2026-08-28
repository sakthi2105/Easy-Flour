const mongoose = require('mongoose');

const productionSchema = mongoose.Schema({
  admin: { type: mongoose.Schema.Types.ObjectId, required: true, ref: 'Admin' },
  riceUsedKg: { type: Number, required: true },
  plantUsedKg: { type: Number, required: true },
  flourProducedKg: { type: Number, required: true },
  productionDate: { type: Date, required: true, default: Date.now },
  remarks: { type: String }
}, { timestamps: true });

module.exports = mongoose.model('Production', productionSchema);