const StockSummary = require('../models/StockSummary');

// Initialize stock summary if not exists
const initStockSummary = async (adminId) => {
  let summary = await StockSummary.findOne({ admin: adminId });
  if (!summary) {
    summary = await StockSummary.create({ admin: adminId });
  }
  return summary;
};

// Update stock summary helper
const updateStockSummary = async (adminId, field, amount) => {
  let summary = await initStockSummary(adminId);
  summary[field] += amount;
  await summary.save();
};

module.exports = { initStockSummary, updateStockSummary };
