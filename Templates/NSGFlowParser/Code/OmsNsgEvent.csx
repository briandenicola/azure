using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

[Serializable]
public class OmsNsgEvent
{
    public string SubscriptionId;
    public string ResourceGroup;
    public string NSG;
    public string Rule;
    public string MAC;
    public string DateTime;
    public string SourceIp;
    public string SourcePort;
    public string DestinationIp;
    public string DestinationPort;
    public string TcpOrUdp;
    public string InOrOut;
    public string AllowOrDeny;
}