from neo4j import GraphDatabase, basic_auth

# Database connection
db = GraphDatabase.driver("bolt://localhost:7687", auth=basic_auth("neo4j", "CBDEpassword"))
session = db.session()

# Database clean
def clean():
    session.run("MATCH (n) DETACH DELETE n")

# Database insertion functions
#----------------------------------------------------------------------------------------------------------------------------

# LineItem creation
def insertLineItem(l_ORDERKEY,l_SUPPKEY, l_LINENUMBER,l_QUANTITY,l_EXTENDEDPRICE,l_DISCOUNT,l_TAX,l_RETURNFLAG,l_LINESTATUS,l_SHIPDATE):
	session.run("CREATE (:LineItem {ID: '" + l_ORDERKEY + l_LINENUMBER + "', l_ORDERKEY: '"+ l_ORDERKEY + "', l_SUPPKEY: '" + l_SUPPKEY + "', l_LINENUMBER: '" + l_LINENUMBER + "',"+
		"l_QUANTITY: " + l_QUANTITY + ", l_EXTENDEDPRICE: " + l_EXTENDEDPRICE + ", l_DISCOUNT: " + l_DISCOUNT + ", l_TAX: " + l_TAX + ", l_RETURNFLAG: '" + l_RETURNFLAG + "', l_LINESTATUS: '" + l_LINESTATUS + "', l_SHIPDATE: '" + l_SHIPDATE + "'})")
# Part creation
def insertPart(p_PARTKEY,p_MFGR,p_TYPE,p_SIZE):
	session.run("CREATE (:Part {p_PARTKEY: '"+ p_PARTKEY + "', p_MFGR: '"+ p_MFGR + "', p_TYPE: '"+ p_TYPE + "', p_SIZE: "+ p_SIZE + "})")

# Supplier creation
def insertSupplier(supp_SUPPKEY,supp_NAME,supp_ADDRESS,supp_PHONE,supp_ACCTBAL,supp_COMMENT,r_NAME,n_NAME,s_NATIONKEY):
	session.run("CREATE (:Supplier {supp_SUPPKEY: '"+ supp_SUPPKEY + "', supp_NAME: '"+ supp_NAME + "', supp_ADDRESS: '"+ supp_ADDRESS + "', supp_PHONE: '" + supp_PHONE + "', supp_ACCTBAL: " + supp_ACCTBAL + ", supp_COMMENT: '" + supp_COMMENT + "', r_NAME: '" + r_NAME + "', n_NAME: '" + n_NAME + "', s_NATIONKEY: '" + s_NATIONKEY + "'})")

# Orders creation
def insertOrders(o_ORDERKEY,o_ORDERDATE,o_SHIPPRIORITY,c_MKTSEGMENT,c_NATIONKEY):
	session.run("CREATE (:Order {o_ORDERKEY: '"+ o_ORDERKEY + "', o_ORDERDATE: '"+ o_ORDERDATE + "', o_SHIPPRIORITY: "+ o_SHIPPRIORITY + ", c_MKTSEGMENT: '"+ c_MKTSEGMENT + "', c_NATIONKEY: '"+ c_NATIONKEY + "'})")

# LineItem-order Edge creation
def createEdgeLineItemOrders(l_ID, o_ORDERKEY):
	session.run("MATCH (l:LineItem), (o: Order) " +
		"WHERE o.o_ORDERKEY = '" + o_ORDERKEY + "' AND l.ID = '" + l_ID + "' " +
		"CREATE (l)<-[:Contains{name: l.ID + '<->' + o.o_ORDERKEY}]-(o)" +
		"RETURN o,l")

# Supplier-Part Edge creation
def createEdgePartSupplier(p_PARTKEY, supp_SUPPKEY, ps_SUPPLYCOST):
    session.run("MATCH (p: Part), (s: Supplier) " +
        "WHERE p.p_PARTKEY = '" + p_PARTKEY + "' AND s.supp_SUPPKEY = '" + supp_SUPPKEY + "' " +
        "CREATE (p)<-[:PartSupp{Edge: p.p_PARTKEY + '<->' + s.supp_SUPPKEY, ps_SUPPLYCOST: " + ps_SUPPLYCOST + "}]-(s)" +
        "RETURN p,s")

# Supplier-LineItem Edge creation
def createEdgeSupplierLineItem(supp_SUPPKEY, l_ID):
    session.run("MATCH (s: Supplier), (l: LineItem) " +
        "WHERE s.supp_SUPPKEY = '" + supp_SUPPKEY + "' AND l.ID = '" + l_ID + "' " +
        "CREATE (s)<-[:Provider{Edge: s.supp_SUPPKEY + '<->' + l.ID}]-(l)" +
        "RETURN l,s")

def insertions():

	# insertions of LineItem
	insertLineItem('O1', "SUPP1", "1","10.0","20.0","5.0","0.21","E","C","2020-11-12")
	insertLineItem('O2', "SUPP2", "1","10.0","15.0","5.0","0.21","E","R","2020-11-12")
	insertLineItem('O3', "SUPP1", "1","15.0","20.0","5.0","0.21","P","C","2020-11-12")
	insertLineItem('O4', "SUPP1", "1","10.0","20.0","5.0","0.21","C","D","2020-11-12")

	# insertion of Part
	insertPart('P1','ASDHLKADSJF','LFJKASFADJAFL1','1')
	insertPart('P2','ASDHLKADSJF','LFJKASFADJAFL2','3')
	insertPart('P3','ASDHLKADSJF','LFJKASFADJAFL1','7')
	insertPart('P4','ASDHLKADSJF','LFJKASFADJAFL1','5')

	# insertions of Supplier
	insertSupplier('SUPP1','FJASLDKFJFS','C/ ALCACHOFA','987654321','10.0','BUEN PRODUCTO',"EUROPA",'ESPAÑA','ESP')
	insertSupplier('SUPP2','FJASLDKFJFS','C/ MARIA DEL CARMEN','987654321','10.0','CARMEN?', "EUROPA",'FRANCIA','FR')
	insertSupplier('SUPP3','FJASLDKFJFS','C/ ISAAC PERAL','987654321','10.0','COMPRO ORO',"EUROPA",'ESPAÑA','CH')
	insertSupplier('SUPP4','FJASLDKFJFS','C/ CARRER SANT PERE','987654321','10.0','LOS MEJORES PROVEEDORES', 'AMERICA','ECUADOR','EC')

	# insertions of orders
	insertOrders("O1","2017-11-11", "10", "SEGMENT1", "ESP")
	insertOrders("O2","2017-11-11", "4", "SEGMENT2", "FR")
	insertOrders("O3","2017-11-21", "1", "SEGMENT1", "CH")
	insertOrders("O4","2017-11-11", "10", "SEGMENT4", "PL")

	# LineItem-order Edge creation
	createEdgeLineItemOrders("O11","O1")
	createEdgeLineItemOrders("O21","O2")
	createEdgeLineItemOrders("O31","O3")
	createEdgeLineItemOrders("O41","O4")

	# Supplier-Part Edge creation
	createEdgePartSupplier("P1","SUPP1","5.0")
	createEdgePartSupplier("P2","SUPP2","9.99")
	createEdgePartSupplier("P3","SUPP3","20.0")
	createEdgePartSupplier("P4","SUPP4","500.0")

	# Supplier-LineItem Edge creation
	createEdgeSupplierLineItem('SUPP1','O11')
	createEdgeSupplierLineItem('SUPP2','O21')
	createEdgeSupplierLineItem('SUPP1','O31')
	createEdgeSupplierLineItem('SUPP1','O41')
#----------------------------------------------------------------------------------------------------------------------------

# Queries executed over the database
#----------------------------------------------------------------------------------------------------------------------------

# Execution code of query 1:
def executeQuery1(l_SHIPDATE):
	print('execution of query 1 in process...')
	result = session.run(
						"MATCH (l:LineItem) " +
						"WHERE " +
						  	"l.l_SHIPDATE <= '" + l_SHIPDATE + "' " +
			  			"WITH " +
		  				  	"l.l_RETURNFLAG                                       AS l_returnflag, " 	+
	                        "l.l_LINESTATUS                                   	  AS l_linestatus, " 	+
	                        "SUM(l.l_QUANTITY)                               	  AS sum_qty, " 		+
	                        "SUM(l.l_EXTENDEDPRICE)                          	  AS sum_base_price, " 	+
	                        "SUM(l.l_EXTENDEDPRICE*(1-l.l_DISCOUNT))          	  AS sum_disc_price, " 	+
	                        "SUM(l.l_EXTENDEDPRICE*(1-l.l_DISCOUNT)*(1+l.l_TAX))  AS sum_charge, " 		+
	                        "AVG(l.l_QUANTITY)                               	  AS avg_qty, " 		+
	                        "AVG(l.l_EXTENDEDPRICE)                          	  AS avg_price, " 		+
	                        "AVG(l.l_DISCOUNT)                               	  AS avg_disc, " 		+
	                        "COUNT(*)                                       	  AS count_order " 		+
                        "RETURN " +
	                        "l_returnflag, " 	+
	                        "l_linestatus, " 	+
	                        "sum_qty, " 		+
	                        "sum_base_price, " 	+
	                        "sum_disc_price, " 	+
	                        "sum_charge, " 		+
	                        "avg_qty, " 		+
	                        "avg_price, " 		+
	                        "avg_disc, " 		+
	                        "count_order " 		+
	                     "ORDER BY " +
	                        "l_returnflag       ASC, " +
	                        "l_linestatus       ASC "
						)
	for item in result:
		print(item)

	print('execution of query 1 has finished!\n')

# Execution code of query 2:
def executeQuery2(p_SIZE,p_TYPE,r_NAME):
	print('execution of query 2 in process...')
	subqueryResult = session.run(
		"MATCH (s:Supplier{r_NAME: '" + r_NAME + "'})-[ps:PartSupp]->() " +
		"RETURN MIN(ps.ps_SUPPLYCOST)"
		)
	for item in subqueryResult:
		min_val = item['MIN(ps.ps_SUPPLYCOST)']

	query_result = session.run(
		"MATCH (s:Supplier {r_NAME: '" + r_NAME + "'})-[ps:PartSupp {ps_SUPPLYCOST: " + str(min_val) + "}]->(p:Part {p_SIZE: " + p_SIZE + "}) " +
        "WHERE p.p_TYPE ENDS WITH '" + p_TYPE + "' " +
        "RETURN s.supp_ACCTBAL, s.supp_NAME, s.n_NAME, p.p_PARTKEY, p.p_MFGR, s.supp_ADDRESS, s.supp_PHONE, s.supp_COMMENT"
		)
	for item in query_result:
		print(item)

	print('execution of query 2 has finished!\n')

# Execution code of query 3:
def executeQuery3(c_MKTSEGMENT,date1,date2):
	print('execution of query 3 in process...')
	result = session.run(
		"MATCH (o: Order {c_MKTSEGMENT: '" + c_MKTSEGMENT + "'})-[:Contains]->(l:LineItem) " +
		"WHERE o.o_ORDERDATE < '" + date1 + "' AND l.l_SHIPDATE > '" + date2 + "' " +
		"WITH " +
        	"SUM(l.l_EXTENDEDPRICE*(1-l.l_DISCOUNT)) AS revenue, " +
	        "l.l_ORDERKEY AS l_orderkey, " +
	        "o.o_ORDERDATE AS o_orderdate, "+
	        "o.o_SHIPPRIORITY AS o_shippriority " +
		"RETURN l_orderkey, revenue, o_orderdate, o_shippriority " +
		"ORDER BY " +
			"revenue ASC, " +
			"o_orderdate ASC"
		)
	for item in result:
		print(item)

	print('execution of query 3 has finished!\n')

# Execution code of query 4:
def executeQuery4(r_NAME,date):
	print('execution of query 4 in process...')
	date_1_year =  date[:3] + str(int(date[3])+1) + date[4:]
	result = session.run(
        "MATCH (s:Supplier {r_NAME: '" + r_NAME + "'})<-[:Provider]-(l:LineItem)<-[:Contains]-(o:Order)" +
        "WHERE o.o_ORDERDATE >= '" + date + "'AND " +
            "o.c_NATIONKEY = s.s_NATIONKEY AND " +
            "o.o_ORDERDATE < '" + date_1_year + "' " +
        " WITH " +
        	"s.n_NAME                                    AS n_name, " +
        	"SUM(l.l_EXTENDEDPRICE*(1-l.l_DISCOUNT)) AS revenue " +
        "RETURN n_name, revenue" + #SOLO HAY QUE DEVOLVER N_NAME Y DISCCOUNT PERO NOSE PORQUE REVENUE SALE COMO '0', AUNQUE extendedPrice Y DISCCOUNT SI QUE CO
        " ORDER BY " +
        "      revenue     ASC")

	for item in result:
		print(item)

	print('execution of query 4 has finished!\n')
#----------------------------------------------------------------------------------------------------------------------------
def createIndexes():
	session.run("CREATE INDEX ON :LineItem(l_SHIPDATE)")
	session.run("CREATE INDEX ON :Order(o_ORDERDATE)")

# Execution of the queries
def executeQueries():
	executeQuery1('2020-11-12')
	executeQuery2('1','1','EUROPA')
	executeQuery3('SEGMENT1','2020-11-11','2020-11-11')
	executeQuery4('EUROPA','2017-11-11')

def main():
    clean()
    insertions()
    createIndexes()
    executeQueries()

main()
