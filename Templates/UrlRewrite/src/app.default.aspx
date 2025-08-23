<%@ Page Language="VB" Debug="false" Trace="false" %>                                                                    
<%@ Import Namespace=System.Web %>                                                                                     
                                                                                                                       
<html>                                                                                                                 
        <script language="VB" runat="server">                                                                          
                                                                                                                       
                Sub Page_Load ( src as Object, E as EventArgs )                                                        
                                                                                                                       
                        dim ctx as HttpContext = HttpContext.Current                                                   
                                                                                                                       
                        lblTime.Text = Now()                                                                                                            
                        lblApp.Text = ctx.Request.ServerVariables("APP_POOL_ID")                                       
                                                                                                                       
                End Sub                                                                                                
                                                                                                                       
        </script>                                                                                                      
                                                                                                                       
        <body style="FONT: 8pt verdana">                                                                               
                <form runat="server">                                                                                  
                        The server name is: <%=System.Net.Dns.GetHostName().ToString %>  <BR/>                             
                        The time is now: <asp:Label id="lblTime" runat="server" /> <BR />                                
                        The site name is : <asp:Label id="lblApp" runat="server" /> <BR/>              
                </form>                                                                                                
        </body>                                                                                                        
</html>                                                                                                                