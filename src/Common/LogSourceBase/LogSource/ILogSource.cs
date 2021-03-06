﻿namespace LogFlow.DataModel
{
    using System;
    using System.Collections.Generic;
    using System.Reflection;
    using System.Threading;
    
    public interface ILogSource<out T> where T : DataItemBase
    {
        string Name { get; }
        T this[int index] { get; }
        int Count { get; }

        LogSourceProperties Properties { get; }
        int Tier1Count { get; }
        int Tier2Count { get; }
        IReadOnlyList<string> Templates { get; }

        string GetHtml(IEnumerable<DataItemBase> items, bool withTitle);
        string GetText(IEnumerable<DataItemBase> items, bool withTitle);
        object GetColumnValue(DataItemBase item, int columnIndex);
        IReadOnlyList<PropertyInfo> PropertyInfos { get; }
        IReadOnlyList<ColumnInfoAttribute> ColumnInfos { get; }
        //  object GetColumnValue(int rowIndex, int columnIndex);

        IEnumerable<int> Peek(IFilter filter, int peekCount, CancellationToken token);

        IEnumerable<int> Load(IFilter filter, CancellationToken token);

        IReadOnlyList<IFilter> GroupFilters { get; }
    }
}
