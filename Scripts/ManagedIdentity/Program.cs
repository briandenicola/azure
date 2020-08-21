using System;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Azure.ServiceBus;
using Microsoft.Azure.ServiceBus.Primitives;
using Microsoft.Identity.Client;
using Microsoft.Azure.ServiceBus.InteropExtensions;

namespace servicebus
{
    class Program
    {
        static async Task Main(string[] args)
        {
            var msiTokenProvider = TokenProvider.CreateManagedIdentityTokenProvider();
            QueueClient sendClient = new QueueClient("sb://bjdsb001.servicebus.windows.net/", "data", msiTokenProvider);
            await sendClient.SendAsync(new Message(Encoding.UTF8.GetBytes("This is a test message")));
            await sendClient.CloseAsync();

        }
    }
}
