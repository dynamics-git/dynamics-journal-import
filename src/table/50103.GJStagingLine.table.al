table 50503 "GJ Staging Line"
{
    Caption = 'GJ Staging Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Upload Id"; Guid) { }
        field(2; "Row No."; Integer) { }
        field(10; "Col1"; Text[250]) { }
        field(11; "Col2"; Text[250]) { }
        field(12; "Col3"; Text[250]) { }
        field(13; "Col4"; Text[250]) { }
        field(14; "Col5"; Text[250]) { }
        field(15; "Col6"; Text[250]) { }
        field(16; "Col7"; Text[250]) { }
        field(17; "Col8"; Text[250]) { }
        field(18; "Col9"; Text[250]) { }
        field(19; "Col10"; Text[250]) { }
        field(20; "Col11"; Text[250]) { }
        field(21; "Col12"; Text[250]) { }
        field(22; "Col13"; Text[250]) { }
        field(23; "Col14"; Text[250]) { }
        field(24; "Col15"; Text[250]) { }
        field(25; "Col16"; Text[250]) { }
        field(26; "Col17"; Text[250]) { }
        field(27; "Col18"; Text[250]) { }
        field(28; "Col19"; Text[250]) { }
        field(29; "Col20"; Text[250]) { }
    }

    keys { key(PK; "Upload Id", "Row No.") { Clustered = true; } }
}