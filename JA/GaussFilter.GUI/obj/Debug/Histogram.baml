   M S B A M L   `   `   `  ����H  DLaplaceFilter, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null-clr-namespace:LaplaceFilterLaplaceFilter  5   	   l hSystem.Windows.Controls.DataVisualization.Toolkit, Version=4.0.0.0, Culture=neutral, PublicKeyToken=null�{clr-namespace:System.Windows.Controls.DataVisualization.Charting;assembly=System.Windows.Controls.DataVisualization.Toolkit2System.Windows.Controls.DataVisualization.Charting 5   	       LaplaceFilter.Histogram   5   	   W SPresentationCore, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35R NWindowsBase, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35\ XPresentationFramework, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35D 9http://schemas.microsoft.com/winfx/2006/xaml/presentation    5   	   R NSystem.Xaml, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     5   	   @d2http://schemas.microsoft.com/expression/blend/2008     5   	   Jmc;http://schemas.openxmlformats.org/markup-compatibility/2006     5   	   -localclr-namespace:LaplaceFilter     5   	   �DVC{clr-namespace:System.Windows.Controls.DataVisualization.Charting;assembly=System.Windows.Controls.DataVisualization.Toolkit     5   	     � Title$:  4Katarzyna Kowalczewska - Filtr Laplace'a - Histogram��5	   	   $��643.653��6F   $��1096.749��6W   .��5
      � .+�5   
   >  8System.Windows.Controls.DataVisualization.Charting.Chart  -   5          Name$ mcChart��5   5   
 �� Top$ 80��6    �� Left$ 10��6$   
����İ�$��34,53,45.6,29q�5   )      Series 5      C  =System.Windows.Controls.DataVisualization.Charting.LineSeries  ?  9System.Windows.Controls.DataVisualization.Charting.Series   Title$ Alpha��6!   H  BSystem.Windows.Controls.DataVisualization.Charting.DataPointSeries   IndependentValueBinding 5   	   ��  �� Path$	 Key�   DependentValueBinding 5   	   �� $ Value�	   DataPointStyle	 5      �� 5      
 �� 
TargetTypeF  @System.Windows.Controls.DataVisualization.Charting.LineDataPoint"
  6    .�5      ��  �� Property � �� �� Value
 � ���6;   �� 5       �@J�Opacity$ 0Q�68   5      5        5      $	 Red��6!    5   	   �� $	 Key� 5   	   �� $ Value�	 5      �� 5      "
  6    .�5      ��  � ��
 �  ��6;   �� 5        �@J�Opacity$ 0Q�68   5!      5#        5$      $ Green��6!    5%   	   �� $	 Key� 5&   	   �� $ Value�	 5'      �� 5(      "
  6    .�5)      ��  � ��
 � � �6;   �� 5*       �@J�Opacity$ 0Q�68   5+      5-        5/      $
 Blue��6!    50   	   �� $	 Key� 51   	   �� $ Value�	 52      �� 53      "
  6    .�54      ��  � ��
 ��  �6;   �� 55       �@J�Opacity$ 0Q�68   56      58      5:      �� 5<   
   -   5         ��Name$ 	typeImage��5<      $
��Left=�6'   $��	10,10,0,0q�6B   $
��Wrap=�6U   $��Histogram obrazu ��6i   $	��Top=�6�   5>      5?      