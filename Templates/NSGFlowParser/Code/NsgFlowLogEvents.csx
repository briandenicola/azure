using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

public class NsgFlowEvents
{
    public Record[] records;

    public class Record
    {
        public string time;
        public string systemId;
        public string category;
        public string resourceId;
        public string operationName;
        public Properties properties;
    }

    public class Properties
    {
        public int Version;
        public Flows[] flows;
    }

    public class Flows
    {
        public string rule;
        public Flow[] flows;
    }

    public class Flow
    {
        public string mac;
        public string[] flowTuples;
    }

}