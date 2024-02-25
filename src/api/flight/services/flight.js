'use strict';

/**
 * flight service
 */

const { createCoreService } = require('@strapi/strapi').factories;

module.exports = createCoreService('api::flight.flight');
