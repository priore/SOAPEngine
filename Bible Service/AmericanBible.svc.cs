
using System.Collections.Generic;
using System.ServiceModel;
using System.Web.Services;
using System.Web;
using System.Security.Permissions;
using System.ServiceModel.Activation;

namespace Priore.Bible.Wcf
{
    [
        AspNetHostingPermission(SecurityAction.Demand, Level = AspNetHostingPermissionLevel.Minimal),
        AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal),
        AspNetCompatibilityRequirements(RequirementsMode = AspNetCompatibilityRequirementsMode.Allowed),
        ServiceBehavior(Namespace = "http://www.prioregroup.com", AddressFilterMode = AddressFilterMode.Any)
    ]
    public class AmericanBible : IAmericanBible
    {
        [WebMethod(Description = "Get verse from book name, chapter number and verse number")]
        public BibleBookChapterVerse GetVerse(string BookName, int chapter, int verse)
        {
            Bible.AmericanBible bible = new Bible.AmericanBible();
            return bible.GetVerse(BookName, chapter, verse);
        }

        [WebMethod(Description = "Get verses from book name and chapter number")]
        public List<BibleBookChapterVerse> GetVerses(string BookName, int chapter)
        {
            Bible.AmericanBible bible = new Bible.AmericanBible();
            return bible.GetVerses(BookName, chapter);
        }
    }
}
