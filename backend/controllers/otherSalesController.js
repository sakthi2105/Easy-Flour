const OtherSales = require('../models/OtherSales');

const getOtherSales = async (req, res) => {
  try {
    const sales = await OtherSales.find({ admin: req.admin._id }).sort({ date: -1 });
    res.json(sales);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const createOtherSale = async (req, res) => {
  try {
    let { pocketCount, pocketPrice, pendingAmount, ...rest } = req.body;
    const totalAmount = pocketCount * pocketPrice;

    const sale = await OtherSales.create({
      admin: req.admin._id,
      ...rest,
      pocketCount,
      pocketPrice,
      totalAmount,
      pendingAmount: pendingAmount || 0
    });
    
    res.status(201).json(sale);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const updateOtherSale = async (req, res) => {
  try {
    const oldSale = await OtherSales.findOne({ _id: req.params.id, admin: req.admin._id });
    if (!oldSale) return res.status(404).json({ message: 'Sale not found' });

    let { pocketCount, pocketPrice, pendingAmount, ...rest } = req.body;
    const totalAmount = pocketCount * pocketPrice;

    const updatedSale = await OtherSales.findOneAndUpdate({ _id: req.params.id, admin: req.admin._id }, {
      ...rest,
      pocketCount,
      pocketPrice,
      totalAmount,
      pendingAmount: pendingAmount || 0
    }, { new: true });
    
    res.json(updatedSale);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const deleteOtherSale = async (req, res) => {
  try {
    const sale = await OtherSales.findOne({ _id: req.params.id, admin: req.admin._id });
    if (!sale) return res.status(404).json({ message: 'Sale not found' });
    
    await sale.deleteOne();
    res.json({ message: 'Sale removed' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { getOtherSales, createOtherSale, updateOtherSale, deleteOtherSale };
