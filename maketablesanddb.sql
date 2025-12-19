
-- Create database

CREATE DATABASE IF NOT EXISTS `currency_trend_management`
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

USE `currency_trend_management`;

-- users: stores accounts
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(80) NOT NULL UNIQUE,
  `email` VARCHAR(120) NOT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- currencies: master list of currency codes and names
CREATE TABLE IF NOT EXISTS `currencies` (
  `currency_code` CHAR(3) NOT NULL,
  `currency_name` VARCHAR(120) NOT NULL,
  PRIMARY KEY (`currency_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- exchange_rates (lowercase): app uses this name
CREATE TABLE IF NOT EXISTS `exchange_rates` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `base_currency` CHAR(3) NOT NULL,
  `target_currency` CHAR(3) NOT NULL,
  `exchange_rate` DECIMAL(18,8) NOT NULL,
  `timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_pair` (`base_currency`, `target_currency`),
  INDEX `idx_base` (`base_currency`),
  INDEX `idx_target` (`target_currency`),
  CONSTRAINT `fk_exr_base` FOREIGN KEY (`base_currency`) REFERENCES `currencies` (`currency_code`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_exr_target` FOREIGN KEY (`target_currency`) REFERENCES `currencies` (`currency_code`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exchange_Rates (capitalized): created because a helper script writes to this exact name
CREATE TABLE IF NOT EXISTS `Exchange_Rates` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `base_currency` CHAR(3) NOT NULL,
  `target_currency` CHAR(3) NOT NULL,
  `exchange_rate` DECIMAL(18,8) NOT NULL,
  `timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_pair_cap` (`base_currency`, `target_currency`),
  INDEX `idx_base_cap` (`base_currency`),
  INDEX `idx_target_cap` (`target_currency`),
  CONSTRAINT `fk_Exr_base` FOREIGN KEY (`base_currency`) REFERENCES `currencies` (`currency_code`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_Exr_target` FOREIGN KEY (`target_currency`) REFERENCES `currencies` (`currency_code`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- trend_analysis: historical/time series rates for trend logic
CREATE TABLE IF NOT EXISTS `trend_analysis` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `base_currency` CHAR(3) NOT NULL,
  `target_currency` CHAR(3) NOT NULL,
  `exchange_rate` DECIMAL(18,8) NOT NULL,
  `timestamp` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_ta_base` (`base_currency`),
  INDEX `idx_ta_target` (`target_currency`),
  CONSTRAINT `fk_ta_base` FOREIGN KEY (`base_currency`) REFERENCES `currencies` (`currency_code`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_ta_target` FOREIGN KEY (`target_currency`) REFERENCES `currencies` (`currency_code`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- increased_rates: small table for detected increases
CREATE TABLE IF NOT EXISTS `increased_rates` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `base_currency` CHAR(3) NOT NULL,
  `target_currency` CHAR(3) NOT NULL,
  `old_rate` DECIMAL(18,8) NOT NULL,
  `new_rate` DECIMAL(18,8) NOT NULL,
  `timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_inc_base` (`base_currency`),
  INDEX `idx_inc_target` (`target_currency`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- decreased_rates: small table for detected decreases
CREATE TABLE IF NOT EXISTS `decreased_rates` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `base_currency` CHAR(3) NOT NULL,
  `target_currency` CHAR(3) NOT NULL,
  `old_rate` DECIMAL(18,8) NOT NULL,
  `new_rate` DECIMAL(18,8) NOT NULL,
  `timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_dec_base` (`base_currency`),
  INDEX `idx_dec_target` (`target_currency`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- conversion_history: records conversions by users
CREATE TABLE IF NOT EXISTS `conversion_history` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NULL,
  `from_currency` CHAR(3) NOT NULL,
  `to_currency` CHAR(3) NOT NULL,
  `amount` DECIMAL(30,8) NOT NULL,
  `converted_amount` DECIMAL(30,8) NOT NULL,
  `rate_used` DECIMAL(18,8) NOT NULL,
  `conversion_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_ch_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed currency list (INSERT IGNORE prevents errors if you run the script again)
INSERT IGNORE INTO `currencies` (`currency_code`, `currency_name`) VALUES
('AED','UAE Dirham'),
('AFN','Afghan Afghani'),
('ALL','Albanian Lek'),
('AMD','Armenian Dram'),
('ANG','Netherlands Antillian Guilder'),
('AOA','Angolan Kwanza'),
('ARS','Argentine Peso'),
('AUD','Australian Dollar'),
('AWG','Aruban Florin'),
('AZN','Azerbaijani Manat'),
('BAM','Bosnia and Herzegovina Convertible Mark'),
('BBD','Barbados Dollar'),
('BDT','Bangladeshi Taka'),
('BGN','Bulgarian Lev'),
('BHD','Bahraini Dinar'),
('BIF','Burundian Franc'),
('BMD','Bermudian Dollar'),
('BND','Brunei Dollar'),
('BOB','Bolivian Boliviano'),
('BRL','Brazilian Real'),
('BSD','Bahamian Dollar'),
('BTN','Bhutanese Ngultrum'),
('BWP','Botswana Pula'),
('BYN','Belarusian Ruble'),
('BZD','Belize Dollar'),
('CAD','Canadian Dollar'),
('CDF','Congolese Franc'),
('CHF','Swiss Franc'),
('CLP','Chilean Peso'),
('CNY','Chinese Renminbi'),
('COP','Colombian Peso'),
('CRC','Costa Rican Colón'),
('CUC','Cuban Convertible Peso'),
('CUP','Cuban Peso'),
('CVE','Cape Verdean Escudo'),
('CZK','Czech Koruna'),
('DJF','Djiboutian Franc'),
('DKK','Danish Krone'),
('DOP','Dominican Peso'),
('DZD','Algerian Dinar'),
('EGP','Egyptian Pound'),
('ERN','Eritrean Nakfa'),
('ETB','Ethiopian Birr'),
('EUR','Euro'),
('FJD','Fiji Dollar'),
('FKP','Falkland Islands Pound'),
('FOK','Faroese Króna'),
('GBP','Pound Sterling'),
('GEL','Georgian Lari'),
('GGP','Guernsey Pound'),
('GHS','Ghanaian Cedi'),
('GIP','Gibraltar Pound'),
('GMD','Gambian Dalasi'),
('GNF','Guinean Franc'),
('GTQ','Guatemalan Quetzal'),
('GYD','Guyanese Dollar'),
('HKD','Hong Kong Dollar'),
('HNL','Honduran Lempira'),
('HRK','Croatian Kuna'),
('HTG','Haitian Gourde'),
('HUF','Hungarian Forint'),
('IDR','Indonesian Rupiah'),
('ILS','Israeli New Shekel'),
('IMP','Isle of Man Pound'),
('INR','Indian Rupee'),
('IQD','Iraqi Dinar'),
('IRR','Iranian Rial'),
('ISK','Icelandic Króna'),
('JEP','Jersey Pound'),
('JMD','Jamaican Dollar'),
('JOD','Jordanian Dinar'),
('JPY','Japanese Yen'),
('KES','Kenyan Shilling'),
('KGS','Kyrgyzstani Som'),
('KHR','Cambodian Riel'),
('KID','Kiribati Dollar'),
('KMF','Comorian Franc'),
('KRW','South Korean Won'),
('KWD','Kuwaiti Dinar'),
('KYD','Cayman Islands Dollar'),
('KZT','Kazakhstani Tenge'),
('LAK','Lao Kip'),
('LBP','Lebanese Pound'),
('LKR','Sri Lankan Rupee'),
('LRD','Liberian Dollar'),
('LSL','Lesotho Loti'),
('LYD','Libyan Dinar'),
('MAD','Moroccan Dirham'),
('MDL','Moldovan Leu'),
('MGA','Malagasy Ariary'),
('MKD','Macedonian Denar'),
('MMK','Myanmar Kyat'),
('MNT','Mongolian Tugrik'),
('MOP','Macanese Pataca'),
('MRU','Mauritanian Ouguiya'),
('MUR','Mauritian Rupee'),
('MVR','Maldivian Rufiyaa'),
('MWK','Malawian Kwacha'),
('MXN','Mexican Peso'),
('MYR','Malaysian Ringgit'),
('MZN','Mozambican Metical'),
('NAD','Namibian Dollar'),
('NGN','Nigerian Naira'),
('NIO','Nicaraguan Córdoba'),
('NOK','Norwegian Krone'),
('NPR','Nepalese Rupee'),
('NZD','New Zealand Dollar'),
('OMR','Omani Rial'),
('PAB','Panamanian Balboa'),
('PEN','Peruvian Sol'),
('PGK','Papua New Guinean Kina'),
('PHP','Philippine Peso'),
('PKR','Pakistani Rupee'),
('PLN','Polish Złoty'),
('PYG','Paraguayan Guaraní'),
('QAR','Qatari Riyal'),
('RON','Romanian Leu'),
('RSD','Serbian Dinar'),
('RUB','Russian Ruble'),
('RWF','Rwandan Franc'),
('SAR','Saudi Riyal'),
('SBD','Solomon Islands Dollar'),
('SCR','Seychellois Rupee'),
('SDG','Sudanese Pound'),
('SEK','Swedish Krona'),
('SGD','Singapore Dollar'),
('SHP','Saint Helena Pound'),
('SLE','Sierra Leonean Leone'),
('SLL','Sierra Leonean Leone'),
('SOS','Somali Shilling'),
('SRD','Surinamese Dollar'),
('SSP','South Sudanese Pound'),
('STN','São Tomé and Príncipe Dobra'),
('SYP','Syrian Pound'),
('SZL','Eswatini Lilangeni'),
('THB','Thai Baht'),
('TJS','Tajikistani Somoni');
