create table person (
	id serial not null primary,
	name character varying(50) not null unique
);