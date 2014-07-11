
using System.Collections.Generic;
using System.ServiceModel;

namespace Priore.Bible.Wcf
{
    [ServiceContract(Namespace = "http://www.prioregroup.com")]
    public interface IAmericanBible
    {
        [OperationContract]
        BibleBookChapterVerse GetVerse(string BookName, int chapter, int verse);

        [OperationContract]
        List<BibleBookChapterVerse> GetVerses(string BookName, int chapter);
    }
}
