'use strict';

/**
 * flight controller
 */

const { createCoreController } = require('@strapi/strapi').factories;

module.exports = createCoreController('api::flight.flight');
