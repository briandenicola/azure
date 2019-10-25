package main

import (
	"crypto/tls"
	"encoding/json"
	"fmt"
	"log"
	"net"
	"os"
	"time"
	"io/ioutil"

	"gopkg.in/mgo.v2"
)

var (
	database string
	password string
)

func init() {
	database = "bjdmongo001"
	password = ""
}

func main() {
	dialInfo := &mgo.DialInfo{
		Addrs:    []string{fmt.Sprintf("%s.documents.azure.com:10255", database)},
		Timeout:  60 * time.Second,
		Database: "db001", // It can be anything
		Username: database, // Username
		Password: password, // PASSWORD
		DialServer: func(addr *mgo.ServerAddr) (net.Conn, error) {
			return tls.Dial("tcp", addr.String(), &tls.Config{})
		},
	}
	session, err := mgo.DialWithInfo(dialInfo)

	if err != nil {
		fmt.Printf("Can't connect, go error %v\n", err)
		os.Exit(1)
	}
	defer session.Close()
	session.SetSafe(&mgo.Safe{})

	fmt.Println("Connected to MongoDB!")

	data, err := ioutil.ReadFile("../go.json")

	collection := session.DB("db001").C("loans001")

	var v interface{}
	if err := json.Unmarshal(data, &v); err != nil {
		log.Fatal("Problem  parsing data: ", err)
		return
	}

	err = collection.Insert(v);

	if err != nil {
		log.Fatal("Problem inserting data: ", err)
		return
	}	
}
