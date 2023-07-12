# Создать триггер для поддержки витрины в актуальном состоянии.
```
CREATE OR REPLACE FUNCTION process_good_sum_mart() RETURNS TRIGGER AS $process_good_sum_mart$
    begin
	    
        IF (TG_OP = 'DELETE') then
        	update good_sum_mart
        	set sum_sale = (SELECT sum(G.good_price * S.sales_qty)
			FROM goods G
			INNER JOIN sales S ON S.good_id = G.goods_id 
			where s.good_id = old.good_id
			GROUP BY G.good_name)
        	where good_name = (select good_name from goods g where g.goods_id = old.good_id);
		ELSIF (TG_OP = 'INSERT') then
        	update good_sum_mart
        	set sum_sale = (SELECT sum(G.good_price * S.sales_qty)
			FROM goods G
			INNER JOIN sales S ON S.good_id = G.goods_id 
			where s.good_id = new.good_id
			GROUP BY G.good_name)
        	where good_name = (select good_name from goods g where g.goods_id = new.good_id);	
		ELSIF (TG_OP = 'UPDATE') then
        	update good_sum_mart
        	set sum_sale = (SELECT sum(G.good_price * S.sales_qty)
			FROM goods G
			INNER JOIN sales S ON S.good_id = G.goods_id 
			where s.good_id = new.good_id
			GROUP BY G.good_name)
        	where good_name = (select good_name from goods g where g.goods_id = new.good_id);
        END IF;
        RETURN NULL; -- возвращаемое значение для триггера AFTER игнорируется
    END;
$process_good_sum_mart$ LANGUAGE plpgsql;



CREATE TRIGGER good_sum_mart_trg
AFTER INSERT OR UPDATE OR DELETE ON sales
    FOR EACH ROW EXECUTE FUNCTION process_good_sum_mart();
```
Общий вывод: Выше приведен простейший пример реализации триггера для поддержки витрины в актуальном состоянии. Схема триггер + витрина предпочтительнее как минимум за счет автономности. 
Любые изменения таблицы продаж сразу же отражаются в представлении, что позволяет иметь актуальные данные. 