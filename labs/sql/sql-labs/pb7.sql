use healthcare;
--statement 1
delimiter $$
create procedure find_claim_stat(in disid int)
BEGIN
with dclaim as (
    select `diseaseID`, count(`claimID`) 'cout' from disease inner join treatment using(`diseaseID`)
        inner join claim using(`claimID`) group by `diseaseID`
) select if((select cout from dclaim c where c.diseaseID=disid) > (select avg(cout) from dclaim),
 'claimed higher than average', 'claimed lower than average') 'status';
 end $$
 delimiter ;

 call find_claim_stat(10);

--statement 2

delimiter $$
create procedure pb702(in disid int)
begin
    with octe as (
        with cte as (
            select `diseaseName`,gender,count(`treatmentID`) 'cout' from person
                inner join patient on `personID`= `patientID` inner join treatment using(`patientID`)
                inner join disease using(`diseaseID`) where diseaseID = disid group by gender 
            ) select `diseaseName`, (select cout from cte c where c.diseaseName = d.`diseaseName` and gender = 'male') 'number_of_male_treated',
        (select cout from cte c where c.diseaseName = d.`diseaseName` and gender = 'female') 'number_of_female_treated' from cte d group by `diseaseName`
    ) select `diseaseName`, number_of_male_treated, number_of_female_treated, if(number_of_male_treated > number_of_female_treated,
    'male', if (number_of_male_treated = number_of_female_treated,'same','female')) as 'more_treated_gender' from  octe;

end $$
delimiter ;

set @t = 1;
call pb702(@t);


--statement 3

with cte as (
    (select `companyID`, `planName`,count(`claimID`) 'cout', 'max' as stat from insuranceplan inner join claim using(uin) group by `planName` ORDER BY 3 DESC limit 3)
    union 
    (select `companyID`,`planName`,count(`claimID`), 'min' from insuranceplan inner join claim using(uin) group by `planName` ORDER BY 3 limit 3)
) select planName,(select companyName from insurancecompany c where c.`companyID`=d.`companyID`) 'company_name',
if(stat='max', 'most claimed', 'least claimed') as 'description' from cte d;

--statement 4

delimiter $$
create function g_func(gender varchar(10), dob date)
returns varchar(20) DETERMINISTIC
begin 
declare cat varchar(20);
if gender = 'male' and dob BETWEEN '2005-01-01' and curdate() then set cat = 'YoungMale';
elseif gender = 'female' and dob BETWEEN '2005-01-01' and curdate() then set cat = 'YoungFemale';
elseif gender = 'male' and dob BETWEEN '1985-01-01' and '2004-12-31' then set cat = 'AdultMale';
elseif gender = 'female' and dob BETWEEN '1985-01-01' and '2004-12-31' then set cat = 'AdultFemale';
elseif gender = 'male' and dob BETWEEN '1970-01-01' and '1984-12-31' then set cat = 'MidAgeMale';
elseif gender = 'female' and dob BETWEEN '1970-01-01' and '1984-12-31' then set cat = 'MidAgeFemale';
elseif gender = 'male' and dob < '1970-01-01' then set cat = 'ElderMale';
elseif gender = 'female' and dob < '1970-01-01' then set cat = 'ElderFemale';
end if;
return cat;
end $$
delimiter ;


select `personName`,gender, dob, g_func(gender,dob) as 'catergory' from patient
inner join person on `patientID` = `personID`;

--statement 5


select companyName, productName, description, maxPrice, 
if(maxPrice > 1000 , 'pricely','affordable') as category from medicine order by maxPrice desc;