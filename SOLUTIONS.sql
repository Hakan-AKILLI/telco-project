--Bu projede soruguların sonucunda ID bilgiride listelenmiştir.
--Sebebi ise sorguların sonuçları çalışan bir backend projesine bağlayacak şekilde tasarlandı.
--Eğer sonuçları bir insan okuyacaksa ID dönmek hem gereksiz hem de güvensizdir.

--1.1 'Kobiye Destek' tarifesine abone olan müşterileri listeleyin.
--Müşteri bilgisi ve tarife ismi farklı tablolarda olduğu için öncelikle join kullanarak bu iki tabloyu birleştirdik.
--Burada CUSTOMERS tablosundaki primay key ile TARIFFS tablsoundaki foreign keyi bağlamış olduk.
--Ardından Where keywordünü kullanarak sadece tarifesi 'Kobiye Destek' olan satırları listeledik.
SELECT c.CUSTOMER_ID, c.CUSTOMER_NAME, c.SIGNUP_DATE,t.TARIFF_NAME
FROM CUSTOMERS c 
JOIN TARIFFS t ON t.TARIFF_ID = c.TARIFF_ID 
WHERE t.TARIFF_NAME = 'Kobiye Destek';

--1.2 Bu tarifeye abone olan en yeni müşteriyi bulun.
--1.1'deki sorgunun mantığını koruyarak.Bu sorgunun üzerinde yeni kontroller eklendi.
--ORDER BY ve DESC  keyword'leri kullanılarak müşterilerin giriş tarihleri büyükten küçüğe sıralanıdı.
--FETCH FIRST 1 ROWS ONLY satırında ise kayıt tarihine göre büyükten küçüğe sıralanan sütünlardan en baştaki yani en yeni olan satır seçildi.
SELECT c.CUSTOMER_ID, c.CUSTOMER_NAME, c.SIGNUP_DATE,t.TARIFF_ID ,t.TARIFF_NAME
FROM CUSTOMERS c 
JOIN TARIFFS t ON t.TARIFF_ID = c.TARIFF_ID 
WHERE c.TARIFF_ID = 4
ORDER BY SIGNUP_DATE DESC
FETCH FIRST 1 ROWS ONLY;

--2.1 Müşteriler arasındaki tarife dağılımlarını buluyoruz.
--Müşteri bilgisi ve tarife ismi farklı tablolarda olduğu için öncelikle join kullanarak bu iki tabloyu birleştirdik.
--GROUP BY ile tarife çeşitlerinin gruplara ayrılamsını sağladık.
--Ardından bu gruplardaki satır sayılarını COUNT ile saydık ve bu sonucu kullanıcı sayısı diye yeni sütünda listeldik.
SELECT t.TARIFF_NAME, 
COUNT(*) AS COUNT_USERS 
FROM CUSTOMERS c JOIN TARIFFS t ON t.TARIFF_ID = c.TARIFF_ID
GROUP BY t.TARIFF_NAME;


--3.1 Kayıt olan en eski müşterileri belirleyin.
--Burada iç içe sorgu kullanıldı. Çünkü en eski tarihin ne olduğu ve bu tarihe kaç kişi kayıtolduğu bilnmiyordu.
--Alt sorgu tüm müşteriler arasındaki en küçük tarihi bulur. 
--Ana sorgu ise bu tarihe eşit olan kayıtları listeler.
SELECT c.CUSTOMER_ID, c.CUSTOMER_NAME, c.CITY, c.SIGNUP_DATE
FROM CUSTOMERS c
WHERE c.SIGNUP_DATE = (
    SELECT MIN(SIGNUP_DATE) 
    FROM CUSTOMERS)


--3.2 Bu ilk müşterilerin farklı şehirlerdeki dağılımını ve her şehir için toplam sayıyı bulun.
--Burada 3.1'in çözümündeki mantık korundu.
--GROUP BY ve COUNT kullanrak şehirlein dağılımı bulundu 
SELECT CITY,
COUNT(*) AS CUSTOMER_COUNT
FROM CUSTOMERS
WHERE SIGNUP_DATE = (
       SELECT MIN(SIGNUP_DATE) 
       FROM CUSTOMERS)
GROUP BY CITY
ORDER BY CUSTOMER_COUNT DESC;


--4.1 Bir ekleme hatası meydana gelmiş ve bazı müşterilerin aylık kayıtları eksiktir. Bu eksik müşterilerin kimliklerini (ID) belirleyin. 
--Burada RIGHT/LEFT JOIN kullanmak mantıklı olandı.
--Çünkü LEFT JOIN; CUSTOMERS tablosundaki her satırı alır. Eğer MONTHLY_USAGE tablosunda karşılığı yoksa, o satırın kullanım bilgilerini NULL olarak getirir.
--Is Null ile Id değeri null olan (MONTHLY_USAGE tablosunda olmayan ID'leri) değerleri seçtik.
--ORDER BY ile MONTHLY_USAGE tablosuna girmeyen değerleri sıraladık.
SELECT c.CUSTOMER_ID
FROM CUSTOMERS c
LEFT JOIN MONTHLY_USAGES m ON c.CUSTOMER_ID = m.CUSTOMER_ID
WHERE m.CUSTOMER_ID IS NULL
ORDER BY c.CUSTOMER_ID ASC;



--4.2 Kayıp müşterilerin farklı şehirlerdeki dağılımını bulun.
--Burada CITIES_OF_LOST_CUSTOMERS diye bir View oluşturmak yerine with yapısı kullanıldı.
--Sebebi ise wiew bir kayıt olarak tutulurken. With işleminde oluşan tablo sorgu sırasında geçici bir süre bellekte tutulur.
--Birinci kısımda 4.1' deki sorgunun mantığı korunarak With ile CITIES_OF_LOST_CUSTOMERS adı verilerek bir süre bellekte tutuldu.
--Ikinci ksımda bellekteki CITIES_OF_LOST_CUSTOMERS tablosunda işlemler yapıldı.
--Bu işlemlerde şehriler GROUP BY ile gruplandı ve COUNT ile sayılarak kayıp müşterilerin şehirlere göre sayısı CITIES_OF_LOST_CUSTOMERS olarak yeni bir sütuan eklendi .
WITH CITIES_OF_LOST_CUSTOMERS AS(
SELECT c.CUSTOMER_ID, c.CUSTOMER_NAME,c.CITY 
FROM CUSTOMERS c
LEFT JOIN MONTHLY_USAGES m ON c.CUSTOMER_ID = m.CUSTOMER_ID
WHERE m.CUSTOMER_ID IS NULL
)
SELECT CITY,
COUNT(*) AS CITIES_OF_LOST_CUSTOMERS
FROM CITIES_OF_LOST_CUSTOMERS
GROUP BY CITY 
ORDER BY CITIES_OF_LOST_CUSTOMERS DESC;



--5.1 Veri limitinin en az %75'ini kullanan müşterileri bulun.
--Burada kod tekrarında kaçmak için oluşturduğumz 'V_USAGE_INFORMATION' viewini kullanadık.
--Kullanılan datanıyı, data limitine böldük ve sonucun 0.75 büyük olan satırları alark data limitin %75'ini kullan müşterileri bulduk.
--Data limit >0 kontorolünü ekleyerek de 0' bölme hatasında kaçındık. 
SELECT CUSTOMER_NAME,TARIFF_NAME,DATA_LIMIT,DATA_USAGE 
FROM V_USAGE_INFORMATION
WHERE DATA_LIMIT >0
	AND DATA_USAGE/ DATA_LIMIT > 0.75;


--5.2 Paket limitlerinin (veri, dakika ve SMS) tamamını tüketen müşterileri belirleyin.
--Burada oluşturduğumz 'V_USAGE_INFORMATION' viewini kullanarak paket limitlerini geçen veya tamamen kullanan kullanıcıları buluyoruz
--Where'in içerisinde AND kullanmamız sebebi ise lmitlerin tamamını tüketen müşterileri bulmamız istenmesi.
SELECT *
FROM V_USAGE_INFORMATION
WHERE SMS_USAGE >= SMS_LIMIT
    AND MINUTE_USAGE >= MINUTE_LIMIT
	AND DATA_USAGE >= DATA_LIMIT

--6.1 Ödenmemiş ücretleri olan müşterileri bulun.
--Müşteri bilgisi ve ödeme durumu farklı tablolarda olduğu için öncelikle join kullanarak bu iki tabloyu birleştirdik.
--Burada CUSTOMERS tablosundaki primay key ile MONTHLY_USAGES tablsoundaki foreign keyi bağlamış olduk.
--Ardından Where keywordünü kullanarak sadece ödeme durumu UNPAID  olan satırları listeledik.
SELECT c.CUSTOMER_ID ,c.CUSTOMER_NAME,m.PAYMENT_STATUS 
FROM CUSTOMERS c 
JOIN MONTHLY_USAGES m ON C.CUSTOMER_ID= m.CUSTOMER_ID 
WHERE m.PAYMENT_STATUS ='UNPAID';

  
--6.2 Tüm ödeme durumlarının farklı tarifeler genelindeki dağılımını bulun.
--Müşteri bilgisi ,ödeme durumu ve tarife ismi farklı tablolarda olduğu için öncelikle join kullanarak üç tabloyu birleştirdik.
--Burada CUSTOMERS tablosundaki primay key ile MONTHLY_USAGES ve TARIFFS tablsoundaki foreign keyleri bağlamış olduk.
--Ardından Tarife ismi ve ödeme durumuna göre grupladık ve Count sayarak CUSTOMER_COUNT sütunu ekledik.
--Order by ile tarife ismine sonucu sıraladık.
SELECT t.TARIFF_NAME, m.PAYMENT_STATUS, 
COUNT(t.TARIFF_NAME) AS CUSTOMER_COUNT
FROM CUSTOMERS c 
JOIN MONTHLY_USAGES m ON c.CUSTOMER_ID = m.CUSTOMER_ID
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
GROUP BY t.TARIFF_NAME, m.PAYMENT_STATUS
ORDER BY t.TARIFF_NAME;
  
  
  
  
  
  
  
  
  
  
  
  
