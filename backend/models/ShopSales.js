const mongoose = require('mongoose');

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

module.exports = mongoose.model('ShopSales', shopSalesSchema);
