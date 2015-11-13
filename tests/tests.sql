set client_min_messages to debug2;

select get_byte(mdt, 1), get_byte(mdt, 2) from errors;

select mdt_mins(mdt) from errors;
