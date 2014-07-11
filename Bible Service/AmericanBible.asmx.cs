
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Security.Permissions;
using Priore.Bible.BibleDBTableAdapters;

namespace Priore.Bible
{
    [
        WebService(Namespace = "http://www.prioregroup.com/"),
        WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1),
        System.ComponentModel.ToolboxItem(false),
        System.Web.Script.Services.ScriptService,
        AspNetHostingPermission(SecurityAction.Demand, Level = AspNetHostingPermissionLevel.Minimal),
        AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal)
    ]
    public partial class AmericanBible : System.Web.Services.WebService
    {
        [WebMethod(Description="Get verse from book name, chapter number and verse number")]
        public BibleBookChapterVerse GetVerse(string BookName, int chapter, int verse)
        {
            BibleBookChapterVerse result = new BibleBookChapterVerse();
            BibleDB.americanDataTable dt = new BibleDB.americanDataTable();
            americanTableAdapter tb = new americanTableAdapter();
            tb.FillByBookChapterVerse(dt, BookName, chapter, verse);
            result = dt.Select(i => new BibleBookChapterVerse()
            {
                BookName = (string)i["title"],
                Chapter = (int)i["chapter"],
                Verse = (int)i["verse"],
                Text = (string)i["text"]
            }).FirstOrDefault();

            return result;
        }

        [WebMethod(Description = "Get verses from book name and chapter number")]
        public List<BibleBookChapterVerse> GetVerses(string BookName, int chapter)
        {
            List<BibleBookChapterVerse> result = new List<BibleBookChapterVerse>();
            BibleDB.americanDataTable dt = new BibleDB.americanDataTable();
            americanTableAdapter tb = new americanTableAdapter();
            tb.FillByBookChapter(dt, BookName, chapter);
            result = dt.Select(i => new BibleBookChapterVerse()
            {
                BookName = (string)i["title"],
                Chapter = (int)i["chapter"],
                Verse = (int)i["verse"],
                Text = (string)i["text"]
            }).ToList();

            return result;
        }
    }
}