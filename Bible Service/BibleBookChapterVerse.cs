
using System.Web;
using System.Security.Permissions;
using System.Runtime.Serialization;

namespace Priore.Bible
{
    [
        DataContract,
        System.ComponentModel.ToolboxItem(false),
        AspNetHostingPermission(SecurityAction.Demand, Level = AspNetHostingPermissionLevel.Minimal),
        AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal)
    ]
    public class BibleBookChapterVerse
    {
        [DataMember]
        public string BookName { get; set; }

        [DataMember]
        public int Chapter { get; set; }

        [DataMember]
        public int Verse { get; set; }

        [DataMember]
        public string Text { get; set; }
    }
}
