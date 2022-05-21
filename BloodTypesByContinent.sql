/*

Working with bloodtypes data file scraped with R.

*/

/* -----------------------------------------------------------------------------*/
-- We begin by adjusting the data type for each field. */

USE projects;

select * FROM bloodtypes;

-- Removing percent symbols and commas.
UPDATE bloodtypes 
SET 
Population = REPLACE(Population, ',', ''),
`O+` = REPLACE(`O+`, '%', ''),
`A+` = REPLACE(`A+`, '%', ''),
`B+` = REPLACE(`B+`, '%', ''),
`AB+` = REPLACE(`AB+`, '%', ''),
`O-` = REPLACE(`O-`, '%', ''),
`A-` = REPLACE(`A-`, '%', ''),
`B-` = REPLACE(`B-`, '%', ''),
`AB-` = REPLACE(`AB-`, '%', '');

ALTER TABLE bloodtypes
MODIFY COLUMN Country char(40),
MODIFY COLUMN Population bigint,
MODIFY COLUMN `O+` DECIMAL(5,2),
MODIFY COLUMN `A+` DECIMAL(5,2),
MODIFY COLUMN `B+` DECIMAL(5,2),
MODIFY COLUMN `AB+` DECIMAL(5,2),
MODIFY COLUMN `O-` DECIMAL(5,2),
MODIFY COLUMN `A-` DECIMAL(5,2),
MODIFY COLUMN `B-` DECIMAL(5,2),
MODIFY COLUMN `AB-` DECIMAL(5,2);

select Country, Population,
`O+`*.01 as `O+`, `A+`*.01 as `A+`, `B+`*.01 as `B+`, 
`AB+`*.01 as `AB+`, `O-`*.01 as `O-`, `A-`*.01 as `A-`,
`B-`*.01 as `B-`, `AB-`*.01 as `AB-`
from bloodtypes;
