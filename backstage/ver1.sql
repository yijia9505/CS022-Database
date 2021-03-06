-- MySQL Script generated by MySQL Workbench
-- Thu May 26 08:10:45 2016
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema new_schema
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema new_schema
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `new_schema` ;
USE `new_schema` ;

-- -----------------------------------------------------
-- Table `new_schema`.`customer`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `new_schema`.`customer` (
  `phone` BIGINT NOT NULL,
  `name` VARCHAR(45) NOT NULL,
  `address` VARCHAR(45) NOT NULL,
  `driving_license` INT NOT NULL,
  PRIMARY KEY (`phone`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `new_schema`.`vehicle`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `new_schema`.`vehicle` (
  `liscense` INT AUTO_INCREMENT,
  `type` VARCHAR(45) NOT NULL COMMENT 'Economy, Compact, Mid-size, Standard, Fullsize, Premium, Luxury, SUV, Van',
  `distance` INT NOT NULL DEFAULT 0,
  `buy_year` INT NOT NULL,
  `used` INT NOT NULL DEFAULT 0,
  `stage` VARCHAR(45) NOT NULL COMMENT 'using, in office, reserved',
  `price` INT NOT NULL,
  `gas_capacity` INT NOT NULL,
  PRIMARY KEY (`liscense`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `new_schema`.`office`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `new_schema`.`office` (
  `office_id` INT AUTO_INCREMENT,
  `city` VARCHAR(45) NOT NULL,
  `address` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`office_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `new_schema`.`card`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `new_schema`.`card` (
  `number` INT NOT NULL,
  `expire_time` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`number`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `new_schema`.`reserve`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `new_schema`.`reserve` (
  `customer_phone` BIGINT NOT NULL,
  `vehicle_liscense` INT NOT NULL,
  `reserve_id` INT AUTO_INCREMENT,
  `get_office` INT NOT NULL,
  `return_office` INT NOT NULL,
  `get_time` INT NOT NULL,
  `return_time` INT NOT NULL,
  `price` INT NOT NULL,
  `state` VARCHAR(45) NOT NULL DEFAULT 'reserved' COMMENT '‘reserved’, ‘expired’, ‘canceled’, ‘rent’, ‘finished’',
  INDEX `fk_customer_has_vehicle_vehicle1_idx` (`vehicle_liscense` ASC),
  INDEX `fk_customer_has_vehicle_customer_idx` (`customer_phone` ASC),
  PRIMARY KEY (`reserve_id`),
  INDEX `get_office_idx` (`get_office` ASC, `return_office` ASC),
  CONSTRAINT `customer`
    FOREIGN KEY (`customer_phone`)
    REFERENCES `new_schema`.`customer` (`phone`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `vehicle`
    FOREIGN KEY (`vehicle_liscense`)
    REFERENCES `new_schema`.`vehicle` (`liscense`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `get_office`
    FOREIGN KEY (`get_office` )
    REFERENCES `new_schema`.`office` (`office_id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `return_office`
    FOREIGN KEY (`return_office` )
    REFERENCES `new_schema`.`office` (`office_id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `new_schema`.`office_has_vehicle`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `new_schema`.`office_has_vehicle` (
  `office_office_id` INT NOT NULL,
  `vehicle_liscense` INT NOT NULL,
  INDEX `fk_office_has_vehicle_vehicle1_idx` (`vehicle_liscense` ASC),
  INDEX `fk_office_has_vehicle_office1_idx` (`office_office_id` ASC),
  CONSTRAINT `fk_office_has_vehicle_office1`
    FOREIGN KEY (`office_office_id`)
    REFERENCES `new_schema`.`office` (`office_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_office_has_vehicle_vehicle1`
    FOREIGN KEY (`vehicle_liscense`)
    REFERENCES `new_schema`.`vehicle` (`liscense`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `new_schema`.`rent`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `new_schema`.`rent` (
  `customer_phone` BIGINT NOT NULL,
  `vehicle_liscense` INT NOT NULL,
  `rent_id` INT AUTO_INCREMENT,
  `get_office` INT NOT NULL,
  `get_time` INT NOT NULL,
  `paid_price` INT NOT NULL,
  `card_id` BIGINT NOT NULL,
  `card_expire` INT NOT NULL,  
  `reserve_id` INT NOT NULL,
  INDEX `fk_customer_has_vehicle_vehicle2_idx` (`vehicle_liscense` ASC),
  INDEX `fk_customer_has_vehicle_customer1_idx` (`customer_phone` ASC),
  PRIMARY KEY (`rent_id`),
  INDEX `get_office_id_idx` (`get_office` ASC),
  
  INDEX `rent-reserve_idx` (`reserve_id` ASC),
  CONSTRAINT `phone`
    FOREIGN KEY (`customer_phone`)
    REFERENCES `new_schema`.`customer` (`phone`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `vehicle_id`
    FOREIGN KEY (`vehicle_liscense`)
    REFERENCES `new_schema`.`vehicle` (`liscense`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `get_office_id`
    FOREIGN KEY (`get_office`)
    REFERENCES `new_schema`.`office` (`office_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `rent-reserve`
    FOREIGN KEY (`reserve_id`)
    REFERENCES `new_schema`.`reserve` (`reserve_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `new_schema`.`back`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `new_schema`.`back` (
  `customer_phone` BIGINT NOT NULL,
  `vehicle_liscense` INT NOT NULL,
  `return_id` INT AUTO_INCREMENT,
  `reserve_id` INT NOT NULL,
  `return_office` INT NOT NULL,
  `return_time` INT NOT NULL,
  `gas_remain` INT NOT NULL,
  `price` INT NOT NULL,
  `full_gas` INT NOT NULL,
  INDEX `fk_customer_has_vehicle_vehicle1_idx` (`vehicle_liscense` ASC),
  INDEX `fk_customer_has_vehicle_customer1_idx` (`customer_phone` ASC),
  PRIMARY KEY (`return_id`),
  INDEX `return-office_idx` (`return_office` ASC),
  INDEX `reserve-return_idx` (`reserve_id` ASC),
  CONSTRAINT `customer-return`
    FOREIGN KEY (`customer_phone`)
    REFERENCES `new_schema`.`customer` (`phone`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `return-vehicle`
    FOREIGN KEY (`vehicle_liscense`)
    REFERENCES `new_schema`.`vehicle` (`liscense`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `return-office`
    FOREIGN KEY (`return_office`)
    REFERENCES `new_schema`.`office` (`office_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `reserve-return`
    FOREIGN KEY (`reserve_id`)
    REFERENCES `new_schema`.`reserve` (`reserve_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;
SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


grant ALL privileges on new_schema.customer to customer@localhost identified by '123123';
grant select,insert,update on new_schema.* to customer@localhost identified by '123123';

Insert into office(city,address) Value('Shanghai','800 Dongchuan RD');
Insert into office(city,address) Value('Guangzhou','78 Baiyun RD');
Insert into office(city,address) Value('Beijin','19 King"s RD');
Insert into office(city,address) Value('Fujian','989 Queen"s RD');



Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('economy',2013,'in office',15000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('economy',2013,'in office',15000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('economy',2013,'in office',15000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('economy',2013,'in office',15000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('economy',2013,'in office',15000,100);

Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('economy',2014,'in office',20000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('economy',2014,'in office',20000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('economy',2014,'in office',20000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('economy',2014,'in office',20000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('economy',2014,'in office',20000,100);

Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('economy',2014,'in office',20000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('economy',2014,'in office',20000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('economy',2014,'in office',20000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('economy',2014,'in office',20000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('economy',2014,'in office',20000,100);

Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('economy',2014,'in office',20000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('economy',2014,'in office',20000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('economy',2014,'in office',20000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('economy',2014,'in office',20000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('economy',2014,'in office',20000,100);






Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('compact',2014,'in office',50000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('compact',2014,'in office',50000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('compact',2014,'in office',50000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('compact',2014,'in office',50000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('compact',2014,'in office',50000,100);

Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('compact',2014,'in office',50000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('compact',2014,'in office',50000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('compact',2014,'in office',50000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('compact',2014,'in office',50000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('compact',2014,'in office',50000,100);

Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('compact',2014,'in office',50000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('compact',2014,'in office',50000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('compact',2014,'in office',50000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('compact',2014,'in office',50000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('compact',2014,'in office',50000,100);

Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('compact',2015,'in office',50000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('compact',2015,'in office',50000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('compact',2015,'in office',50000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('compact',2015,'in office',50000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('compact',2015,'in office',50000,100);





Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('mid-size',2014,'in office',60000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('mid-size',2014,'in office',60000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('mid-size',2014,'in office',60000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('mid-size',2014,'in office',60000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('mid-size',2014,'in office',65000,100);

Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('mid-size',2014,'in office',60000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('mid-size',2014,'in office',60000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('mid-size',2014,'in office',60000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('mid-size',2014,'in office',65000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('mid-size',2014,'in office',65000,100);

Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('mid-size',2014,'in office',60000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('mid-size',2014,'in office',60000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('mid-size',2014,'in office',60000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('mid-size',2014,'in office',60000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('mid-size',2014,'in office',65000,100);

Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('mid-size',2014,'in office',60000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('mid-size',2014,'in office',60000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('mid-size',2014,'in office',60000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('mid-size',2014,'in office',65000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('mid-size',2014,'in office',65000,100);






Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('standard',2014,'in office',70000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('standard',2014,'in office',70000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('standard',2014,'in office',70000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('standard',2014,'in office',80000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('standard',2014,'in office',80000,100);

Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('standard',2014,'in office',70000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('standard',2014,'in office',70000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('standard',2014,'in office',70000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('standard',2014,'in office',70000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('standard',2014,'in office',70000,100);

Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('standard',2014,'in office',70000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('standard',2014,'in office',70000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('standard',2014,'in office',70000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('standard',2014,'in office',70000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('standard',2014,'in office',70000,100);

Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('standard',2014,'in office',80000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('standard',2014,'in office',80000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('standard',2014,'in office',80000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('standard',2014,'in office',70000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('standard',2014,'in office',70000,100);

Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('standard',2014,'in office',70000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('standard',2014,'in office',70000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('standard',2014,'in office',70000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('standard',2014,'in office',70000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('standard',2014,'in office',80000,100);





Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('fullsize',2014,'in office',100000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('fullsize',2014,'in office',100000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('fullsize',2014,'in office',100000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('fullsize',2014,'in office',100000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('fullsize',2014,'in office',120000,100);

Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('fullsize',2014,'in office',100000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('fullsize',2014,'in office',100000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('fullsize',2014,'in office',100000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('fullsize',2014,'in office',100000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('fullsize',2014,'in office',120000,100);

Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('fullsize',2014,'in office',100000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('fullsize',2014,'in office',100000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('fullsize',2014,'in office',100000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('fullsize',2014,'in office',100000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('fullsize',2014,'in office',120000,100);



 


Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('premium',2015,'in office',200000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('premium',2015,'in office',200000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('premium',2015,'in office',200000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('premium',2015,'in office',250000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('premium',2015,'in office',250000,100);

Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('premium',2015,'in office',200000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('premium',2015,'in office',200000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('premium',2015,'in office',200000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('premium',2015,'in office',250000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('premium',2015,'in office',200000,100);





Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('luxury',2015,'in office',500000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('luxury',2015,'in office',500000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('luxury',2015,'in office',600000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('luxury',2015,'in office',600000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('luxury',2015,'in office',500000,100);

Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('luxury',2015,'in office',500000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('luxury',2015,'in office',500000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('luxury',2015,'in office',600000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('luxury',2015,'in office',500000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('luxury',2015,'in office',500000,100);




Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('SUV',2015,'in office',300000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('SUV',2015,'in office',300000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('SUV',2015,'in office',250000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('SUV',2015,'in office',250000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('SUV',2015,'in office',250000,100);



Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('van',2014,'in office',80000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('van',2014,'in office',80000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('van',2014,'in office',80000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('van',2014,'in office',80000,100);
Insert into vehicle(type,buy_year,stage,price,gas_capacity) Value('van',2014,'in office',80000,100);




Insert into office_has_vehicle value(1,1);
Insert into office_has_vehicle value(1,2);
Insert into office_has_vehicle value(1,3);
Insert into office_has_vehicle value(1,21);
Insert into office_has_vehicle value(1,22);
Insert into office_has_vehicle value(1,23);
Insert into office_has_vehicle value(1,24);
Insert into office_has_vehicle value(1,41);
Insert into office_has_vehicle value(1,42);
Insert into office_has_vehicle value(1,43);

Insert into office_has_vehicle value(1,44);
Insert into office_has_vehicle value(1,45);
Insert into office_has_vehicle value(1,61);
Insert into office_has_vehicle value(1,62);
Insert into office_has_vehicle value(1,63);
Insert into office_has_vehicle value(1,64);
Insert into office_has_vehicle value(1,65);
Insert into office_has_vehicle value(1,86);
Insert into office_has_vehicle value(1,87);
Insert into office_has_vehicle value(1,88);

Insert into office_has_vehicle value(1,89);
Insert into office_has_vehicle value(1,90);
Insert into office_has_vehicle value(1,91);
Insert into office_has_vehicle value(1,101);
Insert into office_has_vehicle value(1,102);
Insert into office_has_vehicle value(1,103);
Insert into office_has_vehicle value(1,104);
Insert into office_has_vehicle value(1,111);
Insert into office_has_vehicle value(1,112);
Insert into office_has_vehicle value(1,113);

Insert into office_has_vehicle value(1,114);
Insert into office_has_vehicle value(1,121);
Insert into office_has_vehicle value(1,122);
Insert into office_has_vehicle value(1,123);
Insert into office_has_vehicle value(1,126);





Insert into office_has_vehicle value(2,4);
Insert into office_has_vehicle value(2,5);
Insert into office_has_vehicle value(2,6);
Insert into office_has_vehicle value(2,25);
Insert into office_has_vehicle value(2,26);
Insert into office_has_vehicle value(2,27);
Insert into office_has_vehicle value(2,28);
Insert into office_has_vehicle value(2,29);
Insert into office_has_vehicle value(2,46);
Insert into office_has_vehicle value(2,47);

Insert into office_has_vehicle value(2,48);
Insert into office_has_vehicle value(2,49);
Insert into office_has_vehicle value(2,50);
Insert into office_has_vehicle value(2,66);
Insert into office_has_vehicle value(2,67);
Insert into office_has_vehicle value(2,68);
Insert into office_has_vehicle value(2,69);
Insert into office_has_vehicle value(2,70);
Insert into office_has_vehicle value(2,71);
Insert into office_has_vehicle value(2,72);

Insert into office_has_vehicle value(2,73);
Insert into office_has_vehicle value(2,92);
Insert into office_has_vehicle value(2,93);
Insert into office_has_vehicle value(2,94);
Insert into office_has_vehicle value(2,105);
Insert into office_has_vehicle value(2,106);
Insert into office_has_vehicle value(2,115);
Insert into office_has_vehicle value(2,116);
Insert into office_has_vehicle value(2,117);
Insert into office_has_vehicle value(2,124);
Insert into office_has_vehicle value(2,127);



Insert into office_has_vehicle value(3,7);
Insert into office_has_vehicle value(3,8);
Insert into office_has_vehicle value(3,9);
Insert into office_has_vehicle value(3,10);
Insert into office_has_vehicle value(3,30);
Insert into office_has_vehicle value(3,31);
Insert into office_has_vehicle value(3,32);
Insert into office_has_vehicle value(3,33);
Insert into office_has_vehicle value(3,34);
Insert into office_has_vehicle value(3,51);

Insert into office_has_vehicle value(3,52);
Insert into office_has_vehicle value(3,53);
Insert into office_has_vehicle value(3,54);
Insert into office_has_vehicle value(3,55);
Insert into office_has_vehicle value(3,74);
Insert into office_has_vehicle value(3,75);
Insert into office_has_vehicle value(3,76);
Insert into office_has_vehicle value(3,77);
Insert into office_has_vehicle value(3,78);
Insert into office_has_vehicle value(3,79);

Insert into office_has_vehicle value(3,80);
Insert into office_has_vehicle value(3,81);
Insert into office_has_vehicle value(3,95);
Insert into office_has_vehicle value(3,96);
Insert into office_has_vehicle value(3,97);
Insert into office_has_vehicle value(3,107);
Insert into office_has_vehicle value(3,108);
Insert into office_has_vehicle value(3,109);
Insert into office_has_vehicle value(3,118);
Insert into office_has_vehicle value(3,119);
Insert into office_has_vehicle value(3,125);
Insert into office_has_vehicle value(3,128);




Insert into office_has_vehicle value(4,11);
Insert into office_has_vehicle value(4,12);
Insert into office_has_vehicle value(4,13);
Insert into office_has_vehicle value(4,14);
Insert into office_has_vehicle value(4,15);
Insert into office_has_vehicle value(4,16);
Insert into office_has_vehicle value(4,17);
Insert into office_has_vehicle value(4,18);
Insert into office_has_vehicle value(4,19);
Insert into office_has_vehicle value(4,20);

Insert into office_has_vehicle value(4,35);
Insert into office_has_vehicle value(4,36);
Insert into office_has_vehicle value(4,37);
Insert into office_has_vehicle value(4,38);
Insert into office_has_vehicle value(4,39);
Insert into office_has_vehicle value(4,40);
Insert into office_has_vehicle value(4,56);
Insert into office_has_vehicle value(4,57);
Insert into office_has_vehicle value(4,58);
Insert into office_has_vehicle value(4,59);

Insert into office_has_vehicle value(4,60);
Insert into office_has_vehicle value(4,82);
Insert into office_has_vehicle value(4,83);
Insert into office_has_vehicle value(4,84);
Insert into office_has_vehicle value(4,85);
Insert into office_has_vehicle value(4,98);
Insert into office_has_vehicle value(4,99);
Insert into office_has_vehicle value(4,100);
Insert into office_has_vehicle value(4,110);
Insert into office_has_vehicle value(4,120);

Insert into office_has_vehicle value(4,129);
Insert into office_has_vehicle value(4,130);













