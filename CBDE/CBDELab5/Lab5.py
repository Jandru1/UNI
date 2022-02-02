from pymongo import MongoClient
from pymongo.database import Collection, CommandCursor
from pprint import pprint
# connect to MongoDB, change the << MONGODB URL >> to reflect your own connection string
client = MongoClient("mongodb://anas:lab5@cluster0-shard-00-00.agpcw.mongodb.net:27017,cluster0-shard-00-01.agpcw.mongodb.net:27017,cluster0-shard-00-02.agpcw.mongodb.net:27017/lab5?ssl=true&replicaSet=atlas-56zdt6-shard-0&authSource=admin&retryWrites=true&w=majority")
db=client.lab5
# Issue the serverStatus command and print the results
#serverStatusResult=db.command("serverStatus")
#pprint(serverStatusResult)

DATABASE_NAME = 'lab5'

def create_lineitem(data: dict):
    return {
        'id': "{}{}".format(data['l_orderkey'], data['l_linenumber']),

        'l_returnflag': data['l_returnflag'],
        'l_linestatus': data['l_linestatus'],
        'l_quantity': data['l_quantity'],
        'l_extendedprice': data['l_extendedprice'],
        'l_discount': data['l_discount'],
        'l_tax': data['l_tax'],
        'l_shipdate': data['l_shipdate'],
        'l_linenumber': data['l_linenumber'],
        'l_suppkey': data['l_suppkey'],
        'l_orderkey':data['l_orderkey'],

        'orders' : {
                'o_orderdate' : data['orders']['o_orderdate'],
                'o_shippriority': data['orders']['o_shippriority'],
                'customer' : {
                        'c_mktsegment': data['orders']['customer']['c_mktsegment'],
                        'c_nationkey': data['orders']['customer']['c_nationkey'],
                        'nation' : {
                                'n_name': data['orders']['customer']['nation']['n_name'],
                                'region' : {
                                        'r_name': data['orders']['customer']['nation']['region']['r_name'],
                                }
                        }
                }
        },

        'supplier': {
        	's_nationkey': data['supplier']['s_nationkey'],
        	'nation' : {
        		'n_name' : data['supplier']['nation']['n_name'],
        		'region' : {
        			'r_name' : data['supplier']['nation']['region']['r_name'],
        		}
        	}
        }
    }


def create_partsup(data: dict):
    return {
        'id': "{}{}".format(data['ps_partkey'], data['ps_suppkey']),

        'ps_partkey': data['ps_partkey'],
        'ps_suppkey':data['ps_suppkey'],
        'ps_supplycost': data['ps_supplycost'],

        'part' : {
            'p_mfgr': data['part']['p_mfgr'],
            'p_size': data['part']['p_size'],
            'p_type': data['part']['p_type'],
        },

        'supplier' : {
            's_acctbal': data['supplier']['s_acctbal'],
            's_name': data['supplier']['s_name'],
            's_address': data['supplier']['s_address'],
            's_phone': data['supplier']['s_phone'],
            's_comment': data['supplier']['s_comment'],
            's_nationkey': data['supplier']['s_nationkey'],
            'nation' : {
                'n_name': data['supplier']['nation']['n_name'],
                'region' : {
                    'r_name': data['supplier']['nation']['region']['r_name'],
                }
            }
        }
    }


def query1(collection: Collection, date: str):
      return collection.aggregate([

        {"$match": {
            "l_shipdate": {"$lte": date}
        }},

        {"$project": {
            "l_returnflag": "$l_returnflag",
            "l_linestatus": "$l_linestatus",
            "l_quantity": "$l_quantity",
            "l_extendedprice": "$l_extendedprice",
            "l_discount": "$l_discount",
            "l_tax": "$l_tax"
        }},

        {"$group": {
            "_id": {"l_returnflag": "$l_returnflag", "l_linestatus": "$l_linestatus"},
            "l_returnflag": {"$first": "$l_returnflag"},
            "l_linestatus": {"$first": "$l_linestatus"},
            "sum_qty": {"$sum": "$l_quantity"},
            "sum_base_price": {"$sum": "$l_extendedprice"},
            "sum_disc_price": {"$sum": {"$multiply": ["$l_extendedprice", {"$subtract": [1, "$l_discount"]}]}},
            "sum_charge": {"$sum": {
                "$multiply": [{"$multiply": ["$l_extendedprice", {"$subtract": [1, "$l_discount"]}]},
                              {"$add": [1, "$l_tax"]}]}},
            "avg_qty": {"$avg": "$l_quantity"},
            "avg_price": {"$avg": "$l_extendedprice"},
            "avg_disc": {"$avg": "$l_discount"},
            "count_order": {"$sum": 1}
        }},

        {"$sort": {
            "l_returnflag": 1,
            "l_linestatus": 1
        }}
    ])

def query2(collection: Collection, region: str, size: int, Type: str):
	return collection.aggregate([

		{"$match": {
			"$and": [
            	{"part.p_size": {"$eq": size}},
            	{"supplier.nation.region.r_name": {"$eq": region}},
            	{"part.p_type": {"$regex": Type}},
            	{"ps_supplycost": {"$eq":subquery2(collection,region,size,Type)}}
            ]
    	}},

    	{"$project": {
    		"supplier.s_acctbal": "$supplier.s_acctbal",
    		"supplier.s_name":"$supplier.s_name",
    		"supplier.nation.n_name":"$supplier.nation.n_name",
    		"ps_partkey":"$ps_partkey",
    		"part.p_mfgr":"$part.p_mfgr",
    		"supplier.s_address":"$supplier.s_address",
    		"supplier.s_phone":"$supplier.s_phone",
    		"supplier.s_comment":"$supplier.s_comment"

    	}},

    	{"$sort": {
            "s_acctbal": -1,
            "n_name": 1,
            "s_name":1,
            "ps_partkey":1
    	}}
    ])



def subquery2(collection: Collection, region: str, size: int, Type: str):
    try:
        return collection.aggregate([

            {"$match":     {
                    "$and": [
                    {"part.p_size": {"$eq": size}},
                    {"supplier.nation.region.r_name": {"$eq": region}},
                    {"part.p_type": {"$regex": Type}},
                    ]
            }},

            {"$project":{
                "ps_supplycost" : "$ps_supplycost"
            }},

            {"$group":{
                "_id":None,
                "min_supplycost":{"$min": "$ps_supplycost"}
            }}

        ]).next()['min_supplycost']

    except StopIteration:
        print("IteratorError")


def query3(collection: Collection, segment: str, date1: str, date2: str ):
	return collection.aggregate([

		{"$match":     {
			"$and": [
			{"orders.customer.c_mktsegment" : {"$eq": segment}},
			{"orders.o_orderdate": {"$lt": date1}},
			{"l_shipdate": {"$gt": date2}}
			]
        }},

        {"$project":{
        	"l_orderkey": "$l_orderkey",
        	"l_extendedprice": "$l_extendedprice",
        	"l_discount": "$l_discount",
        	"orders.o_orderdate" : "$orders.o_orderdate",
        	"orders.o_shippriority": "$orders.o_shippriority"
        }},

        {"$group":{
        	"_id": {"l_orderkey": "$l_orderkey","o_orderdate":"$orders.o_orderdate", "o_shippriority": "$orders.o_shippriority"},
        	"l_orderkey": {"$first": "$l_orderkey"},
        	"revenue": {"$sum": {"$multiply": ["$l_extendedprice", {"$subtract": [1, "$l_discount"]}]}},
        	"o_orderdate": {"$first": "$orders.o_orderdate"},
            "o_shippriority": {"$first": "$orders.o_shippriority"}
        }},

        {"$sort":{
        	"revenue": -1,
        	"o_orderdate":1
        }}
	])

def query4(collection: Collection, date: str, region: str):
	return collection.aggregate([

		{"$match":{
			"$and": [
			{"orders.o_orderdate" : {"$gte": date}},
			{"supplier.nation.region.r_name" : {"$eq": region }},
			{"orders.o_orderdate" : {"$lt": date[:3] + str(int(date[3])+1) + date[4:]}}
			]
		}},

		{"$redact":
			{"$cond": [
				{"$eq":["$supplier.s_nationkey" , "$orders.customer.c_nationkey"]},
				"$$KEEP" , "$$PRUNE"
			]
		}},

		{"$project": {
			"l_extendedprice" : "$l_extendedprice",
			"l_discount": "$l_discount",
			"supplier.nation.n_name" : "$supplier.nation.n_name"
		}},

		{"$group":{
			"_id": {"n_name": "$supplier.nation.n_name"},
			"n_name" : {"$first": "$supplier.nation.n_name"},
			"revenue": {"$sum": {"$multiply": ["$l_extendedprice", {"$subtract": [1, "$l_discount"]}]}}
		}},

		{"$sort": {
			"revenue" : -1
		}}
	])


def insert_docsPart(collection: Collection):
	doc1 = {
		'ps_partkey': 1 ,
        'ps_suppkey':1,
        'ps_supplycost':4.5 ,

        'part' : {
            'p_mfgr': "p_mfgr1",
            'p_size': 4 ,
            'p_type': "type1",
        },

        'supplier' : {
            's_acctbal': 3.2 ,
            's_name': "Supply1" ,
            's_address': "Address1" ,
            's_phone': "675894038" ,
            's_comment': "Comment1",
            's_nationkey': 1 ,
            'nation' : {
                'n_name': "Nation1" ,
                'region' : {
                    'r_name': "Region1" ,
                }
            }
        }
	}

	doc2 = {
		'ps_partkey':2 ,
        'ps_suppkey':2,
        'ps_supplycost':3.2,

        'part' : {
            'p_mfgr': "p_mfgr2" ,
            'p_size': 3 ,
            'p_type': "type2" ,
        },
        'supplier' : {
            's_acctbal': 2.2 ,
            's_name': "Supply2" ,
            's_address': "Address2" ,
            's_phone': "678590937" ,
            's_comment': "Comment2" ,
            's_nationkey': 2 ,
            'nation' : {
                'n_name': "Nation2" ,
                'region' : {
                    'r_name': "Region2" ,
                }
            }
        }
	}

	doc3 = {
		'ps_partkey':3 ,
        'ps_suppkey':3,
        'ps_supplycost':4.2,

        'part' : {
            'p_mfgr': "p_mfgr2" ,
            'p_size': 3,
            'p_type': "type2" ,
        },
        'supplier' : {
            's_acctbal': 2.2 ,
            's_name': "Supply3" ,
            's_address': "Address3" ,
            's_phone': "435390937" ,
            's_comment': "Comment3" ,
            's_nationkey': 3 ,
            'nation' : {
                'n_name': "Nation3" ,
                'region' : {
                    'r_name': "Region3" ,
                }
            }
        }
	}
	data = [doc1, doc2, doc3]
	for d in data:
		document = create_partsup(d)
		collection.insert_one(document)

def insert_docsLine(collection: Collection) :
    doc1 = {
        'l_linenumber': 1,
        'l_returnflag': "Flag1",
        'l_linestatus': "Status1",
        'l_quantity': 3.14,
        'l_extendedprice': 9.7,
        'l_discount': 0.2,
        'l_shipdate': "2020-12-27",
        'l_tax': 0.2,
        'l_suppkey': 10,

        'l_orderkey': 1,

        'orders' : {
            'o_orderdate':"2020-1-1",
            'o_shippriority':1,
            'customer' : {
                    'c_mktsegment':"Segment1" ,
                    'c_nationkey': 2,
                    'nation' : {
                            'n_name': "Nation2",
                            'region' : {
                                    'r_name':"Region1",
                            },
                    },
            },
        },
        'supplier': {
        	's_nationkey': 2 ,
        	'nation' : {
        		'n_name' :"Nation2" ,
        		'region' : {
        			'r_name': "Region1",
        		},
        	},
        },
    }

    doc2 = {
        'l_linenumber': 2,
        'l_returnflag': "Flag2",
        'l_linestatus': "Status2",
        'l_quantity': 3.15,
        'l_extendedprice': 9.8,
        'l_discount': 0.2,
        'l_shipdate': "2020-12-28",
        'l_tax': 0.2,
        'l_suppkey': 10,
        'l_orderkey': 2,

        'orders' : {
            'o_orderdate':"2020-1-2",
            'o_shippriority':2,
            'customer' : {
                    'c_mktsegment':"Segment2" ,
                    'c_nationkey': 3,
                    'nation' : {
                            'n_name': "Nation3",
                            'region' : {
                                    'r_name':"Region2",
                            },
                    },
            },
        },
        'supplier': {
        	's_nationkey': 3 ,
        	'nation' : {
        		'n_name' :"Nation3" ,
        		'region' : {
        			'r_name': "region2",
        		},
        	},
        },
    }

    doc3 = {
        'l_linenumber': 3,
        'l_returnflag': "Flag3",
        'l_linestatus': "Status3",
        'l_quantity': 4.15,
        'l_extendedprice': 9.4,
        'l_discount': 0.4,
        'l_shipdate': "2020-12-02",
        'l_tax': 0.3,
        'l_suppkey': 11,
        'l_orderkey': 3,

        'orders' : {
            'o_orderdate':"2020-1-2",
            'o_shippriority': 1,
            'customer' : {
                    'c_mktsegment':"Segment3" ,
                    'c_nationkey': 4,
                    'nation' : {
                            'n_name': "Nation4",
                            'region' : {
                                    'r_name':"Region4",
                            },
                    },
            },
        },
        'supplier': {
        	's_nationkey': 5,
        	'nation' : {
        		'n_name' :"Nation4" ,
        		'region' : {
        			'r_name': "Region4",
        		},
        	},
        },
    }

    data = [doc1, doc2, doc3]
    for d in data:
        document = create_lineitem(d)
        collection.insert_one(document)

def create_lineitem_collection():
    print('Creating LineItem collection...')

    client.drop_database(DATABASE_NAME)

    db = client.get_database(DATABASE_NAME)
    return db.get_collection('LINEITEM')


def create_partsup_collection():
	print('Creating Partsup collection')
	db = client.get_database(DATABASE_NAME)
	return db.get_collection('PARTSUP')


def main():
    collection1 = create_lineitem_collection()
    insert_docsLine(collection1)
    result1 = query1(collection1, "2020-12-29")
    collection2 = create_partsup_collection()
    insert_docsPart(collection2)
    result2 = query2(collection2,"Region1", 4 , "type1")
    result3 = query3(collection1, "Segment1","2020-2-3", "2020-12-26")
    result4 = query4(collection1,"2020-1-1","Region1")
    print ("---------Resultado de la query 1---------")
    for a in result1:
    	pprint(a)
    print ("---------Resultado de la query 2---------")
    for b in result2:
    	pprint(b)
    print ("---------Resultado de la query 3---------")
    for c in result3:
    	pprint(c)
    print ("---------Resultado de la query 4---------")
    for d in result4:
    	pprint(d)

main()
