const RiceStock = require('../models/RiceStock');
const { updateStockSummary } = require('../utils/stockHelper');

const getRiceStocks = async (req, res) => {
  try {
    const stocks = await RiceStock.find({ admin: req.admin._id }).sort({ date: -1 });
    res.json(stocks);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const createRiceStock = async (req, res) => {
  try {
    const stock = await RiceStock.create({ ...req.body, admin: req.admin._id });
    await updateStockSummary(req.admin._id, 'totalRiceKg', req.body.riceKg);
    res.status(201).json(stock);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const updateRiceStock = async (req, res) => {
  try {
    const oldStock = await RiceStock.findOne({ _id: req.params.id, admin: req.admin._id });
    if (!oldStock) return res.status(404).json({ message: 'Stock not found' });

    const diff = req.body.riceKg - oldStock.riceKg;
    const updatedStock = await RiceStock.findOneAndUpdate({ _id: req.params.id, admin: req.admin._id }, req.body, { new: true });
    
    if (diff !== 0) {
      await updateStockSummary(req.admin._id, 'totalRiceKg', diff);
    }
    
    res.json(updatedStock);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const deleteRiceStock = async (req, res) => {
  try {
    const stock = await RiceStock.findOne({ _id: req.params.id, admin: req.admin._id });
    if (!stock) return res.status(404).json({ message: 'Stock not found' });
    
    await updateStockSummary(req.admin._id, 'totalRiceKg', -stock.riceKg);
    await stock.deleteOne();
    
    res.json({ message: 'Stock removed' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { getRiceStocks, createRiceStock, updateRiceStock, deleteRiceStock };
