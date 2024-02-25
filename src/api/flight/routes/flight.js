'use strict';

/**
 * flight router
 */

const { createCoreRouter } = require('@strapi/strapi').factories;

module.exports = createCoreRouter('api::flight.flight');
