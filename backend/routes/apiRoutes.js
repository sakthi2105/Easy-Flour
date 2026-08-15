const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');

const { getRiceStocks, createRiceStock, updateRiceStock, deleteRiceStock } = require('../controllers/riceStockController');
const { getPlantStocks, createPlantStock, updatePlantStock, deletePlantStock } = require('../controllers/plantStockController');
const { getProductions, createProduction, updateProduction, deleteProduction } = require('../controllers/productionController');
const { getShopSales, createShopSale, updateShopSale, deleteShopSale } = require('../controllers/shopSalesController');
const { getOtherSales, createOtherSale, updateOtherSale, deleteOtherSale } = require('../controllers/otherSalesController');
const { getExpenses, createExpense, updateExpense, deleteExpense } = require('../controllers/expenseController');
const { getRevenueDashboard } = require('../controllers/revenueController');

// All routes here are protected
router.use(protect);

// Rice Routes
router.route('/rice').get(getRiceStocks).post(createRiceStock);
router.route('/rice/:id').put(updateRiceStock).delete(deleteRiceStock);

// Plant Routes
router.route('/plant').get(getPlantStocks).post(createPlantStock);
router.route('/plant/:id').put(updatePlantStock).delete(deletePlantStock);

// Production Routes
router.route('/production').get(getProductions).post(createProduction);
router.route('/production/:id').put(updateProduction).delete(deleteProduction);

// Shop Sales Routes
router.route('/shopsales').get(getShopSales).post(createShopSale);
router.route('/shopsales/:id').put(updateShopSale).delete(deleteShopSale);

// Other Sales Routes
router.route('/othersales').get(getOtherSales).post(createOtherSale);
router.route('/othersales/:id').put(updateOtherSale).delete(deleteOtherSale);

// Expense Routes
router.route('/expense').get(getExpenses).post(createExpense);
router.route('/expense/:id').put(updateExpense).delete(deleteExpense);

// Revenue
router.route('/revenue').get(getRevenueDashboard);

module.exports = router;
