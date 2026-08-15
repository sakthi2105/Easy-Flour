const ShopSales = require('../models/ShopSales');
const { updateStockSummary } = require('../utils/stockHelper');

const getShopSales = async (req, res) => {
  try {
    const sales = await ShopSales.find().sort({ salesDate: -1 });
    res.json(sales);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const createShopSale = async (req, res) => {
  try {
    let { pocketCount, pocketPrice, collectionReceived, ...rest } = req.body;
    const totalAmount = pocketCount * pocketPrice;
    const pendingAmount = totalAmount - (collectionReceived || 0);

    const sale = await ShopSales.create({
      ...rest,
      pocketCount,
      pocketPrice,
      totalAmount,
      collectionReceived: collectionReceived || 0,
      pendingAmount
    });
    
    // We could potentially update flour stock if a sale means flour left the stock.
    // The requirements say "Increase Flour Stock Automatically" on production, but 
    // it doesn't explicitly mention "Decrease Flour Stock on Sale". However, it's 
    // usually implied. Let's decrease flour stock based on pockets sold. 
    // Assuming 1 pocket = some kg, or maybe flour stock is not decremented here.
    // I will leave it as is unless specified otherwise.

    res.status(201).json(sale);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const updateShopSale = async (req, res) => {
  try {
    const oldSale = await ShopSales.findById(req.params.id);
    if (!oldSale) return res.status(404).json({ message: 'Sale not found' });

    let { pocketCount, pocketPrice, collectionReceived, ...rest } = req.body;
    
    const totalAmount = pocketCount * pocketPrice;
    const pendingAmount = totalAmount - (collectionReceived || 0);

    const updatedSale = await ShopSales.findByIdAndUpdate(req.params.id, {
      ...rest,
      pocketCount,
      pocketPrice,
      totalAmount,
      collectionReceived: collectionReceived || 0,
      pendingAmount
    }, { new: true });
    
    res.json(updatedSale);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const deleteShopSale = async (req, res) => {
  try {
    const sale = await ShopSales.findById(req.params.id);
    if (!sale) return res.status(404).json({ message: 'Sale not found' });
    
    await sale.deleteOne();
    res.json({ message: 'Sale removed' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { getShopSales, createShopSale, updateShopSale, deleteShopSale };
