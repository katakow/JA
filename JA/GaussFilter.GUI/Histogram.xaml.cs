using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Controls.DataVisualization.Charting;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

namespace LaplaceFilter
{
    /// <summary>
    /// Interaction logic for Histogram.xaml
    /// </summary>
    public partial class Histogram : Window
    {
        private int[] pixelCountA = new int [256];
        private int[] pixelCountR = new int[256];
        private int[] pixelCountG = new int[256];
        private int[] pixelCountB = new int[256];
        private Bitmap imagus;
        private const int BYTES_IN_PIXEL = 4;

        public Histogram(Bitmap image)
        {
            if (image != null)
            {
                InitializeComponent();
                this.imagus = image;
                countPixels();
                LoadColumnChartData();
            }
            else
            {
                throw new Exception("Brak obrazu");
            }

        }

        private void countPixels()
        {
           for (int y = 0; y < this.imagus.Height; y++)
            {
                for (int x = 0; x < this.imagus.Width; x++)
                {
                    this.pixelCountA[this.imagus.GetPixel(x, y).A]++;
                    this.pixelCountR[this.imagus.GetPixel(x, y).R]++;
                    this.pixelCountG[this.imagus.GetPixel(x, y).G]++;
                    this.pixelCountB[this.imagus.GetPixel(x, y).B]++;
                }
            }
        }

        private void LoadColumnChartData()
        {
            KeyValuePair<int, int>[] dataA = new KeyValuePair<int, int>[256];
            for (int i = 0; i < 256; i++) 
            {
                dataA[i]=(new KeyValuePair<int, int>(i, this.pixelCountA[i]));
            }


            KeyValuePair<int, int>[] dataR = new KeyValuePair<int, int>[256];
            for (int i = 0; i < 256; i++)
            {
                dataR[i] = (new KeyValuePair<int, int>(i, this.pixelCountR[i]));
            }


            KeyValuePair<int, int>[] dataG = new KeyValuePair<int, int>[256];
            for (int i = 0; i < 256; i++)
            {
                dataG[i] = (new KeyValuePair<int, int>(i, this.pixelCountG[i]));
            }


            KeyValuePair<int, int>[] dataB = new KeyValuePair<int, int>[256];
            for (int i = 0; i < 256; i++)
            {
                dataB[i] = (new KeyValuePair<int, int>(i, this.pixelCountB[i]));
            }


            ((LineSeries)mcChart.Series[0]).ItemsSource = dataA;
            ((LineSeries)mcChart.Series[1]).ItemsSource = dataR;
            ((LineSeries)mcChart.Series[2]).ItemsSource = dataG;
            ((LineSeries)mcChart.Series[3]).ItemsSource = dataB;
        }
    }
}

public class PixelCount {

    public int value { get; set; }
    public int count { get; set; }
}

