-- Table pour les transactions bancaires (optionnelle mais utile pour l'historique)
CREATE TABLE IF NOT EXISTS `bank_transactions` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(60) NOT NULL,
    `type` VARCHAR(50) NOT NULL,
    `amount` INT NOT NULL,
    `from_identifier` VARCHAR(60) DEFAULT NULL,
    `to_identifier` VARCHAR(60) DEFAULT NULL,
    `date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Note: La colonne 'bank' dans la table 'users' est généralement déjà présente dans jaksam_core
-- Si ce n'est pas le cas, décommentez la ligne ci-dessous:
-- ALTER TABLE `users` ADD COLUMN `bank` INT NOT NULL DEFAULT 0;

-- Vérifier que la colonne bank existe
-- Si vous utilisez jaksam_core, cette colonne devrait déjà exister
-- Sinon, exécutez cette requête pour l'ajouter:

-- ALTER TABLE `users` ADD COLUMN IF NOT EXISTS `bank` INT NOT NULL DEFAULT 0;
